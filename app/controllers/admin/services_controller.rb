class Admin::ServicesController < InheritedResources::Base
  include Admin::AdminControllerMixin

  def create
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
end
