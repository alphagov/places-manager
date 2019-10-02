require "mapit_api"

ActionController::Renderers.add :csv do |places, _options|
  if places.first.is_a?(Place)
    filename = "#{places.first.data_set.service.slug}.csv"

    headers["Cache-Control"]             = "must-revalidate, post-check=0, pre-check=0"
    headers["Content-Disposition"]       = "attachment; filename=#{filename}"
    headers["Content-Type"]              = "text/csv"
    headers["Content-Transfer-Encoding"] = "binary"

    self.response_body = DataSetCsvPresenter.new(places.first.data_set).to_csv
  end
end

class PlacesController < ApplicationController
  respond_to :json, :kml, :csv

  rescue_from MapitApi::InvalidPostcodeError, with: :error_400
  rescue_from MapitApi::ValidPostcodeNoLocation, with: :error_400

  def show
    # Show a set of places in relation to a service
    # Parameters:
    #   id: the slug for the service
    #   lat, lng: latitude/longitude in decimal degrees to limit the set of
    #             places displayed
    #   max_distance: maximum distance in miles from the lat/long given
    #   limit: maximum number of places to show
    @service = Service.where(slug: params[:id]).first
    head 404 && return if @service.nil?

    data_set = select_data_set(@service, params[:version])
    head 404 && return if data_set.nil?

    max_distance = if params[:max_distance].present?
                     Distance.new(Float(params[:max_distance]), :miles)
                   end

    if params[:postcode].present?
      @places = data_set.places_for_postcode(params[:postcode], max_distance, params[:limit])
    elsif params[:lat].present? && params[:lng].present?
      # TODO: should we handle parsing errors here?
      location = Point.new(latitude: params[:lat], longitude: params[:lng])

      @places = data_set.places_near(location, max_distance, params[:limit])
    else
      @places = data_set.places
    end

    respond_with(@places)
  end

protected

  def error_400(error)
    error_message = error.message.gsub("MapitApi::", "").camelize(:lower)
    render status: :bad_request, json: { error: error_message.to_s }
  end

  def select_data_set(service, version = nil)
    if user_signed_in? && version.present?
      service.data_sets.find(version)
    else
      service.active_data_set
    end
  end
end
