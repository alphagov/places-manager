class Admin::PlacesController < InheritedResources::Base
  include Admin::AdminControllerMixin
  actions :all, except: %i[show index]
  belongs_to :service
  belongs_to :data_set

  def new
    @place = parent.places.build
    unless @place.can_edit?
      flash[:danger] = "You cannot create a new place as " + (data_set.active? ? "this data set is currently active." : "there is a more recent data set available.")
      redirect_to admin_service_data_set_path(@service, @data_set)
    end
  end

  def edit
    unless place.can_edit?
      flash[:danger] = "You cannot edit this place as " + (data_set.active? ? "this data set is currently active." : "there is a more recent data set available.")
      redirect_to admin_service_data_set_path(@service, @data_set)
    end
  end

  def create
    @place = parent.places.build(place_params)
    head(:unprocessable_entity) && return unless @place.can_edit?
    create!
  end

  def update
    head(:unprocessable_entity) && return unless place.can_edit?
    update!
  end

protected

  def service
    @service ||= Service.find(params["service_id"])
  end

  def data_set
    @data_set ||= service.data_sets.find(params["data_set_id"])
  end

  def place
    @place ||= Place.where(data_set_version: data_set.version, service_slug: service.slug).find(params["id"])
  end

  def place_params
    params.
      require(:place).
      permit(
        :name,
        :address1,
        :address2,
        :town,
        :postcode,
        :override_lng,
        :override_lat,
        :snac,
        :url,
        :email,
        :phone,
        :fax,
        :text_phone,
        :access_notes,
        :general_notes,
      )
  end
end
