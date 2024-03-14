require "active_support/concern"

module Admin
  module FileUpload
    extend ActiveSupport::Concern

    class MissingFileError < StandardError; end

    included do
      rescue_from CSV::MalformedCSVError, with: :bad_csv
      rescue_from InvalidCharacterEncodingError, with: :bad_encoding
      rescue_from Encoding::UndefinedConversionError, with: :bad_encoding
      rescue_from MissingFileError, with: :missing_csv
    end

    def get_file_from_param(param)
      if param.respond_to?(:tempfile)
        param.tempfile
      else
        param
      end
    end

    def prohibit_non_csv_uploads
      raise MissingFileError unless params[param_key][:data_file]

      file = get_file_from_param(params[param_key][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.csv?
        message = "Rejecting file with content type: #{fv.mime_type}"
        Rails.logger.info(message)
        params[param_key].delete(:data_file)
        raise CSV::MalformedCSVError.new(message, 0)
      end
    end

    def param_key
      resource_class.name.underscore.to_sym
    end
  end
end
