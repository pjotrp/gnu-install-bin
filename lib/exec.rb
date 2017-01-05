module Exec

  def init options
    @options = options
    debug "Exec #{@options}"
  end

  def shell cmd
    debug "RUN "+cmd if @options[:debug2]
    res = if @options[:debug] or @options[:verbose]
            `#{cmd}`.strip
          else
            `#{cmd} 2>/dev/null`.strip
          end
    retval = $?.exitstatus >> 8
    if retval != 0
      error "exit status #{retval} for #{cmd}"
    end
    res
  end

  def patchelf cmd
    shell @options[:patchelf] + " " + cmd
  end

  def guix_relocate cmd
    shell @options[:guix_relocate] + " " + cmd
  end

end
