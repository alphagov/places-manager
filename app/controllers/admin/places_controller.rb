class Admin::PlacesController < InheritedResources::Base
  include Admin::Defaults
  include Admin::Permissions

  actions :show
  belongs_to :service
  belongs_to :data_set
  before_action :check_permission!
  before_action :set_breadcrumbs

protected

  def set_breadcrumbs
    @breadcrumbs = [
      { title: "Services", url: "/" },
      { title: service.name, url: admin_service_path(service) },
      { title: "Data sets", url: admin_service_data_sets_path(service) },
      { title: "Version #{data_set.version}", url: admin_service_data_set_path(service, data_set) },
      { title: "Place #{resource.id}: #{resource.name}", url: resource_path(resource) },
    ]
  end

  def service
    @service ||= Service.find(params["service_id"])
  end

  def data_set
    @data_set ||= service.data_sets.find(params["data_set_id"])
  end

  def check_permission!
    return if permission_for_service?(service)

    raise PermissionDeniedException, "Sorry, you do not have permission to view places for this service."
  end
end
