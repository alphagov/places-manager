class Admin::DataSetsController < InheritedResources::Base
  defaults :route_prefix => 'admin'
  actions :all, :except => [:show, :index]
  before_filter :authenticate_user!
  belongs_to :service
  rescue_from CSV::MalformedCSVError, :with => :bad_csv
  
  def bad_csv
    flash[:alert] = "Could not process CSV file. Please check the format."
    redirect_to :back
  end
  
  def activate
    msg = resource.activate! ? "Data Set #{resource.version} successfully activated" : "Couldn't activate data set"
    redirect_to admin_service_url(@service), :notice => msg
  end
end
