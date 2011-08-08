class Admin::DataSetsController < InheritedResources::Base
  before_filter :authenticate_user!
  defaults :route_prefix => 'admin'
  belongs_to :service
 
  def create
    create! { admin_service_url(@service) }
  end
  
  def update
    update! { admin_service_url(@service) }
  end
end
