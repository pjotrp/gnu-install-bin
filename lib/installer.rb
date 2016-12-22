require "open3"

module Installer

  def text_file?(fn)
    file_type, status = Open3.capture2e("file", fn)
    status.success? && file_type.include?("text")
  end

  # Find the referenced path and return it with the position in the file
  def parse_real_references(dir,line)
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

  # Create a shorter version of the store path. It does not matter because
  # there won't be collisions between relocated packages - they have different
  # target paths
  def reduce_store_path fn
    i = fn.index( /gnu\/store\/./ )
    if i == nil
      error "Can not reduce store path #{fn}"
    end
    "gnu/"+fn[i+10..i+19]+'-'+fn[i+43..-1]
  end

  def relocate_binary fn, all_refs, targetref
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
              info "Found #{r2} and replacing with #{n}"
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
