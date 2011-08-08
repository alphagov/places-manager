class Admin::ServicesController < InheritedResources::Base
  before_filter :authenticate_user!
  defaults :route_prefix => 'admin'
end
