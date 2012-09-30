module Imminence
  class FileVerifier
    attr_accessor :filename

    def initialize(file)
      if file.respond_to?(:path)
        @filename = file.path
      else
        @filename = file.to_s
      end
    end

    def get_mime_type
      shell_result = IO.popen(["file", "--brief", "--mime-type", filename],
        in: :close, err: :close)
      shell_result.read.chomp
    end

    def is_mime_type?(mime_type)
      get_mime_type == mime_type
    end
  end
end