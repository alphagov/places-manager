class Admin::PlacesController < InheritedResources::Base
  include Admin::AdminControllerMixin
  actions :all, :except => [:show, :index]
  belongs_to :service
  belongs_to :data_set

  def edit
    unless resource.can_edit?
      flash[:alert] = 'You cannot edit this place as ' + (data_set.active? ? 'this data set is currently active.' : "there is a more recent data set available.")
      redirect_to admin_service_data_set_path(@service, @data_set)
    end
  end

  def update
    head(:unprocessable_entity) and return unless resource.can_edit?
    update!
  end

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
