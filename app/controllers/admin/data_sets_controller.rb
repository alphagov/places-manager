require "csv"

class Admin::DataSetsController < InheritedResources::Base
  include Admin::AdminControllerMixin

  actions :all, :except => [:show, :index]
  belongs_to :service
  rescue_from CSV::MalformedCSVError, :with => :bad_csv
  rescue_from BSON::InvalidStringEncoding, :with => :bad_encoding
  rescue_from HtmlValidationError, :with => :bad_html

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
end
