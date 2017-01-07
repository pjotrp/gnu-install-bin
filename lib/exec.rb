module Exec

  def init options
    @options = options
    debug "Exec #{@options}"
  end

  def shell cmd, handle_error = nil
    debug "RUN "+cmd if @options[:debug2]
    res = if @options[:debug] or @options[:verbose]
            `#{cmd}`.strip
          else
            `#{cmd} 2>/dev/null`.strip
          end
    if handle_error
      handle_error.call($?.exitstatus)
    else
      if not $?.success?
        error "exit status #{$?.exitstatus} for #{cmd}"
      end
    end
    res
  end

  def patchelf cmd
    shell @options[:patchelf] + " " + cmd
  end

  def guix_relocate cmd
    shell @options[:guix_relocate] + " -v -d " + cmd
  end

end
