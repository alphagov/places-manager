require 'imminence/file_verifier'
require 'csv'

class Admin::ServicesController < InheritedResources::Base
  include Admin::AdminControllerMixin

  def create
    prohibit_non_csv_uploads
    create!
  rescue CSV::MalformedCSVError => e
    flash.now[:alert] = "Could not process CSV file. Please check the format."
    @service = Service.new(params[:service])
    render action: 'new'
  rescue BSON::InvalidStringEncoding => e
    flash.now[:alert] = "Could not process CSV file because of the file encoding. Please check the format."
    @service = Service.new(params[:service])
    render action: 'new'
  end

  protected
  def prohibit_non_csv_uploads
    if params[:service][:data_file]
      file = get_file_from_param(params[:service][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.type == 'text'
        Rails.logger.info "Rejecting file with content type: #{fv.mime_type}"
        params[:service].delete(:data_file)
        raise CSV::MalformedCSVError
      end
    end
  end
end
