require 'imminence/file_verifier'
require 'csv'


class Admin::ServicesController < InheritedResources::Base
  include Admin::AdminControllerMixin

  def create
    prohibit_invalid_uploads
    create!
  rescue CSV::MalformedCSVError => e
    flash.now[:alert] = "Could not process CSV file. Please check the format."
    @service = Service.new(params[:service])
    render action: 'new'
  rescue BSON::InvalidStringEncoding, InvalidCharacterEncodingError => e
    flash.now[:alert] = "Could not process CSV file because of the file encoding. Please check the format."
    @service = Service.new(params[:service])
    render action: 'new'
  end

  protected
  def prohibit_invalid_uploads
    if params[:service][:data_file]
      file = get_file_from_param(params[:service][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.type == 'text' or fv.sub_type == 'zip'
        Rails.logger.info "Rejecting file with content type: #{fv.mime_type}"
        params[:service].delete(:data_file)
        raise InvalidUploadError
      end
    end
  end
end
