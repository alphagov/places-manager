require "imminence/file_verifier"
require "csv"

class Admin::ServicesController < InheritedResources::Base
  include Admin::AdminControllerMixin

  def create
    prohibit_non_csv_uploads
    create!
  rescue CSV::MalformedCSVError
    flash.now[:danger] = "Could not process CSV file. Please check the format."
    @service = Service.new(service_params)
    render action: "new"
  rescue InvalidCharacterEncodingError
    flash.now[:danger] = "Could not process CSV file because of the file encoding. Please check the format."
    @service = Service.new(service_params)
    render action: "new"
  end

protected

  def prohibit_non_csv_uploads
    if params[:service][:data_file]
      file = get_file_from_param(params[:service][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.type == "text"
        message = "Rejecting file with content type: #{fv.mime_type}"
        Rails.logger.info(message)
        params[:service].delete(:data_file)
        raise CSV::MalformedCSVError.new(message, 0)
      end
    end
  end

  def service_params
    permitted_params = %i[name slug source_of_data location_match_type local_authority_hierarchy_match_type]
    permitted_params << :data_file if %w(create new).include? action_name.to_s
    params.
      require(:service).
      permit(*permitted_params)
  end
end
