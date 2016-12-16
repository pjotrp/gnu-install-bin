
module Messages

  def init options
    @options = options
  end

  def info message
    return if not @options[:verbose]
    $stderr.print message.to_s+"\n"
  end

  def debug message
    return if not @options[:debug]
    $stderr.print message.to_s+"\n"
  end

  def error message
    $stderr.print message.to_s+"\n"
    raise message
  end

end
