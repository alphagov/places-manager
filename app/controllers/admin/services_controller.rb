class Admin::ServicesController < InheritedResources::Base
  before_filter :authenticate_user!
  defaults :route_prefix => 'admin'
  
  def create
    create!
  rescue CSV::MalformedCSVError => e
    flash.now[:alert] = "Could not process CSV file. Please check the format."
    @service = Service.new(params[:service])
    render :action => 'new'
  end
end
