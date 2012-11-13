class Admin::PlacesController < InheritedResources::Base
  include Admin::AdminControllerMixin
  actions :all, :except => [:show, :index]
  belongs_to :service
  belongs_to :data_set

  protected
    def service
      @service ||= Service.find(params['service_id'])
    end

    def data_set
      @data_set ||= service.data_sets.find(params['data_set_id'])
    end

    def resource
      @place ||= Place.where(data_set_version: data_set.version, service_slug: service.slug).find(params['id'])
    end
end
