require "open3"

module Installer

  def init options
    @options = options
    debug "Installer: #{@options}"
  end

  def text_file?(fn)
    file_type, status = Open3.capture2e("file", fn)
    status.success? && file_type.include?("text")
  end

  # Return refs (or nil)
  def get_all_refs(fn, addrec)
    result = shell "strings -t d #{fn}|grep '/gnu/store/'"
    if result == ""
      addrec.call(fn, { type: :file } )
      nil
    else
      info "Contains /gnu/store reference in #{fn}"
      debug result
      result.split("\n").map {|line|
        parse_real_references(line)
      }
    end
  end

  # Find the referenced path and return it with the position in the file
  def parse_real_references(line)
    i,s = line.split(nil,2)
    a1 = s.split(/\/gnu\/store\//).delete_if { |w| w == "" }.map { |item| "./gnu/store/"+item }
    refs = a1.map { |fn|
      validate_ref(fn)
    }.compact

    info "Located refs in #{refs.to_s}"
    # make sure at least one ref is real
    error "Could not find valid refs in #{line}" if refs.size == 0
    [ i.to_i, refs ]
  end

  # Create a new version of the store path. It does not matter what it
  # ends up being because there won't be collisions between relocated
  # packages - they have different target paths
  def reduce_store_path fn, target_dir
    i = fn.index( /gnu\/store\/\w/ )
    if i == nil
      error "Can not reduce store path #{fn}"
    end
    if @options[:strategy] == :fixed
      # use different path layout - should be the same in guix-relocate tool
      p1 = fn[i+10..-1]
      sub_paths = p1.split("/")
      items = sub_paths[0].split("-")
      p2 = items[1..-1].join("-") + "-" + items[0] + "padpadpadpadpadpadpadpadpad"
      # p p1,p2
      newsize = sub_paths[0].size-target_dir.size+"/gnu/store".size
      p2[0..newsize-1]+"/"+sub_paths[1..-1].join("/")
    else
      "gnu/"+fn[i+43..-1]
    end
  end

  def guix_relocate_file fn, fnref, prefix
    include Exec
    Exec.init(@options)
    outfn = prefix + "/" + fnref
    cmd = " --prefix "+prefix+" --origin `pwd` ./"+fn
    # p ["****",cmd]
    guix_relocate(cmd)
  end

  def relocate_binary fn, all_refs, targetref
    rpath_s = patchelf "--print-rpath #{fn}"
    rpaths = rpath_s.strip.split(/:/)
    new_rpath_s = rpaths.map { |rp|
      targetref.call(reduce_store_path(rp))
    }.join(":")
    File.chmod(0755,fn)
    patchelf "--set-rpath #{new_rpath_s} #{fn}"
    interpreter = patchelf "--print-interpreter #{fn}"
    if interpreter != ""
      # p interpreter
      new_interpreter = targetref.call(reduce_store_path(interpreter))
      res1 = patchelf "--set-interpreter #{new_interpreter} #{fn}"
      debug res1
    end
    # OK, done patching with patchelf. Now we need to see what is left and
    # patch that in raw. Note that patchelf has changed the file locations
    # so we need to reload positions
    result = shell "strings -t d #{fn}|grep '/gnu/store/'"
    if result != "" and fn !~ /-bash-static/
      debug "Hard patching #{fn}"
      debug result
      rs = result.split("\n").map {|line|
        parse_real_references(line)
      }
      rs.each { | rec |
        pos = rec[0]
        rec[1].each { | r |
          # p r
          r2 = r[1..-1] # strip leading dot
          next if r2 == "/gnu/store//"
          n = targetref.call(reduce_store_path(r2))
          info "Found #{r2} and replacing with #{n} in #{fn}"
          if n.size > r2.size
            error "Sorry, reference can not increase in size. #{n} is larger than #{r2} in #{fn}\nUse a shorter prefix/install path!"
          else
            File.open("newpath","wb") do |f|
              f.printf "/lib64/ld-linux-x86-64.so.2\x00"
            end
            # debug "dd if=newpath of=#{fn} obs=1 seek=#{pos} conv=notrunc"
            res = shell "dd if=newpath of=#{fn} obs=1 seek=#{pos} conv=notrunc"
            debug res
            File.unlink("newpath")
          end
        }
      }
    end
  end

  def relocate_text fn, all_refs, targetref
    File.open(fn+".patched","w") do |fnew|
      File.open(fn).each_line do | line |
        # Get all references and order them longest first
        rs = all_refs.map { | line_refs |
          line_refs[1].map { |ref|
            ref
          }
        }.flatten.uniq.sort_by {|x| -x.length}

        replace_all_refs = lambda { |s,rx|
          rx.each { | r |
            r2 = r[1..-1] # strip leading dot
            # p r2
            if s.include?(r2)
              n = targetref.call(reduce_store_path(r2))
              info "Found #{r2} and replacing with #{n} in #{fn}"
              s.gsub!(r2,n)
            end
          }
          s
        }
        fnew.write(replace_all_refs.call(line,rs))
      end
    end
    # On success rename files
    File.unlink(fn)
    File.rename(fn+'.patched',fn)
  end

  private

  # Return filename or nil when invalid. Strip characters of fn until
  # it returns a valid path. We store a local path './gnu/store' to make
  # sure we don't accidentally confuse the main /gnu/store.
  def validate_ref(fn)
    stripper = lambda { |s|
      # Strip one letter at a time until we get a hit
      if s == "./gnu/store/" or s == ""
        nil
      else
        begin
          File.lstat(s)
          if s !~ /^\.\/gnu\/store/
            error "Valid reference is pointing outside the store: #{s}"
          end
          debug "Valid reference #{s}"
          s
        rescue Errno::ENOENT
          if s == ""
            nil
          else
            stripper.call(s.chop)
          end
        end
      end
    }
    debug "Validating <#{fn}>"
    if fn =~ /^\.\/gnu\/store\/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-/
      fn
    else
      stripper.call(fn)
    end
  end
end
