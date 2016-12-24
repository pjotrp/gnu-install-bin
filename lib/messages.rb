
module Messages

  def init options
    @options = options
  end

  def info message
    return if not @options[:verbose]
    $stderr.print message.to_s+"\n"
  end

  def warning message
    return if @options[:quiet]
    $stderr.print "WARNING "+message.to_s+"\n"
  end

  def debug message
    return if not @options[:debug]
    $stderr.print "DEBUG "+message.to_s+"\n"
  end

  def error message
    $stderr.print "ERROR "+message.to_s+"\n" if @options[:debug]
    raise message
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

end
