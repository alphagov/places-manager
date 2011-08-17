class Admin::DataSetsController < InheritedResources::Base
  before_filter :authenticate_user!
  defaults :route_prefix => 'admin'
  belongs_to :service
 
  def create
    create! { admin_service_url(@service) }
  rescue CSV::MalformedCSVError => e
    flash[:alert] = "Could not process CSV file. Please check the format."
    redirect_to :back
  end

  def update
    update! { admin_service_url(@service) }
  end
  
  def activate
    msg = resource.activate! ? "Data Set #{resource.version} successfully activated" : "Couldn't activate data set"
    redirect_to admin_service_url(@service), :notice => msg
  end
end
