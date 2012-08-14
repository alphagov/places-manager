ActionController::Renderers.add :csv do |detailed_report, options|
  if detailed_report.first.is_a?(Place)
    filename = "#{detailed_report.first.data_set.service.slug}.csv"

    headers['Cache-Control']             = 'must-revalidate, post-check=0, pre-check=0'
    headers['Content-Disposition']       = "attachment; filename=#{filename}"
    headers['Content-Type']              = 'text/csv'
    headers['Content-Transfer-Encoding'] = 'binary'

    self.response_body = DataSetCsvPresenter.new(detailed_report.first.data_set).to_csv
  end
end

class PlacesController < ApplicationController
  respond_to :json, :kml, :csv

  def show
    # Show a set of places in relation to a service
    # Parameters:
    #   id: the slug for the service
    #   lat, lng: latitude/longitude in decimal degrees to limit the set of
    #             places displayed
    #   max_distance: maximum distance in miles from the lat/long given
    #   limit: maximum number of places to show
    @service = Service.where(slug: params[:id]).first
    head 404 and return if @service.nil?

    data_set = select_data_set(@service, params[:version])
    head 404 and return if data_set.nil?

    if params[:lat].present? && params[:lng].present?
      location = [params[:lat], params[:lng]]
      @places = data_set.places_near(
        location,
        params[:max_distance],
        params[:limit]
      )
    else
      @places = data_set.places
    end

    respond_with(@places)
  end

  protected
  def select_data_set(service, version = nil)
    if user_signed_in? and version.present?
      service.data_sets.find(version)
    else
      service.active_data_set
    end
  end

  def places_for(data_set, lat, lng, max_distance, limit = 50)
    places = data_set.places

    if lat.present? && lng.present? && max_distance.present?
      places = places.near_within_miles(lat.to_f, lng.to_f, max_distance.to_f)
    elsif lat.present? && lng.present?
      places = places.near(location: [lat, lng])
    end

    places.limit(limit)
  end
end
