
module Messages

  def init options
    @options = options
  end

  def info message
    return if not @options[:verbose]
    $stderr.print message.to_s+"\n"
  end

  def warning message
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

end
