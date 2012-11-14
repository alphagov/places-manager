require "csv"

class Admin::DataSetsController < InheritedResources::Base
  include Admin::AdminControllerMixin

  actions :all, :except => [:index, :destroy]
  belongs_to :service
  rescue_from CSV::MalformedCSVError, :with => :bad_csv
  rescue_from BSON::InvalidStringEncoding, :with => :bad_encoding
  rescue_from HtmlValidationError, :with => :bad_html

  def create
    prohibit_non_csv_uploads
    create!
  end

  def duplicate
    duplicated_data_set = resource.duplicate
    flash[:notice] = "Version #{duplicated_data_set.version} has been created."
    redirect_to admin_service_data_set_path(@service, duplicated_data_set)
  end

  def bad_encoding
    flash[:alert] = "Could not process CSV file because of the file encoding. Please check the format."
    redirect_to :back
  end

  def bad_csv
    flash[:alert] = "Could not process CSV file. Please check the format."
    redirect_to :back
  end

  def bad_html
    flash[:alert] = "CSV file contains invalid HTML content. Please check the format."
    redirect_to :back
  end

  def activate
    msg = resource.activate! ? "Data Set #{resource.version} successfully activated" : "Couldn't activate data set"
    redirect_to admin_service_url(@service), :notice => msg
  end

  protected
  def prohibit_non_csv_uploads
    if params[:data_set] && params[:data_set][:data_file]
      file = get_file_from_param(params[:data_set][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.type == 'text'
        Rails.logger.info "Rejecting file with content type: #{fv.mime_type}"
        raise CSV::MalformedCSVError
      end
    end
  end
end
