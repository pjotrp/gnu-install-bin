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
          info "YES! #{s}"
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
    info "Validating <#{fn}>"
    if fn =~ /^\.\/gnu\/store\/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-/
      fn
    else
      stripper.call(fn)
    end
  end
end
