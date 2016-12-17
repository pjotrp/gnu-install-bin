require "open3"

module Installer

  def text_file?(fn)
    file_type, status = Open3.capture2e("file", fn)
    status.success? && file_type.include?("text")
  end
end
