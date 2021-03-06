
module Messages

  def init options
    @options = options
    debug "Message: #{@options}"
  end

  def debug_debug message
    return if not @options[:debug]==2
    $stderr.print "DEBUG "+message.to_s+"\n"
  end

  def debug message
    return if not @options[:debug]
    $stderr.print "DEBUG "+message.to_s+"\n"
  end

  def info message
    return if not @options[:verbose]
    $stderr.print message.to_s+"\n"
  end

  def warning message
    return if @options[:quiet]
    $stderr.print "WARNING "+message.to_s+"\n"
  end

  def error message
    $stderr.print "ERROR "+message.to_s+"\n" if @options[:debug]
    raise message
  end

end
