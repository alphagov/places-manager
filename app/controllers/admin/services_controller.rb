require 'imminence/file_verifier'

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
      fv = Imminence::FileVerifier.new(params[:service][:data_file].tempfile)
      unless fv.is_mime_type?('text/csv') || fv.is_mime_type?('text/plain')
        raise CSV::MalformedCSVError
      end
    end
  end
end
