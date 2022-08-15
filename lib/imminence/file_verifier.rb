module Imminence
  class FileVerifier
    attr_accessor :filename

    CSV_TYPES = [
      "text/csv",         # Ideal, per RFC4180
      "text/plain",       # Current per remote system
      "application/csv",  # Current per docker
    ].freeze

    def initialize(file)
      @filename = if file.respond_to?(:path)
                    file.path
                  else
                    file.to_s
                  end
    end

    def csv?
      return true if File.extname(@filename) == ".csv"

      CSV_TYPES.include?(mime_type)
    end

    def type
      mime_type.split("/").first
    end

    def sub_type
      mime_type.split("/").last
    end

    def mime_type
      `file --brief --mime-type #{filename.shellescape}`.chomp
    end

    def is_mime_type?(comparison_mime_type)
      mime_type == comparison_mime_type
    end
  end
end
