require "csv"
require "imminence/file_verifier"

class Admin::DataSetsController < InheritedResources::Base
  include Admin::AdminControllerMixin

  actions :all, except: %i[new index destroy]
  belongs_to :service
  rescue_from CSV::MalformedCSVError, with: :bad_csv
  rescue_from InvalidCharacterEncodingError, with: :bad_encoding

  def create
    prohibit_non_csv_uploads
    create! do |_success, failure|
      failure.html { render "new_data" }
    end
  end

  def duplicate
    DuplicateDataSetWorker.perform_async(resource.service.id.to_s, resource.id.to_s)
    flash[:success] = "Your request for a duplicate of data set version #{resource.version} is being processed. This can take a few minutes. Please refresh this page."
    redirect_to "#{admin_service_path(service)}#history"
  end

  def activate
    if resource.activate
      flash[:success] = "Data Set #{resource.version} successfully activated"
      resource.service.schedule_archive_places if resource.latest_data_set?
    else
      flash[:danger] = "Couldn't activate data set"
    end
    redirect_to admin_service_url(service)
  end

protected

  def bad_encoding
    flash[:danger] = "Could not process CSV file because of the file encoding. Please check the format."
    redirect_back(fallback_location: admin_service_url(service))
  end

  def bad_csv
    flash[:danger] = "Could not process CSV file. Please check the format."
    redirect_back(fallback_location: admin_service_url(service))
  end

  def prohibit_non_csv_uploads
    if params[:data_set] && params[:data_set][:data_file]
      file = get_file_from_param(params[:data_set][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.type == "text"
        message = "Rejecting file with content type: #{fv.mime_type}"
        Rails.logger.info(message)
        raise CSV::MalformedCSVError.new(message, 0)
      end
    end
  end

  def data_set_params
    params.
      require(:data_set).
      permit(
        :data_file,
        :change_notes,
      )
  end

  def service
    # This is ActiveAdmin's accessor for the service object. We are calling it
    # directly rather than using the @ accessor.
    parent
  end
end
