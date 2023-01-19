require "gds_api/exceptions"

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

  rescue_from GdsApi::HTTPBadRequest, with: :error_400_invalid_postcode
  rescue_from GdsApi::HTTPNotFound, with: :error_400_valid_postcode

  def show
    # Show a set of places in relation to a service
    # Parameters:
    #   id: the slug for the service
    #   postcode: postcode to find from
    #   lat, lng: latitude/longitude in decimal degrees to limit the set of
    #             places displayed
    #   local_authority_slug: local authority slug to search within (only valid
    #                         for local_authority type searches, used in
    #                         split-postcode disambiguation)
    #   max_distance: maximum distance in miles from the lat/long given
    #   limit: maximum number of places to show
    #
    #   If you specify postcode, it takes precedence over lat/lng.
    #   You should only specify local_authority_slug if you also specify postcode
    #
    @service = Service.where(slug: params[:id]).first
    head 404 && return if @service.nil?

    data_set = select_data_set(@service, params[:version])
    head 404 && return if data_set.nil?

    max_distance = if params[:max_distance].present?
                     Distance.new(Float(params[:max_distance]), :miles)
                   end

    if params[:postcode].present?
      @places = data_set.places_for_postcode(params[:postcode], max_distance, params[:limit], params[:local_authority_slug])
    elsif params[:lat].present? && params[:lng].present?
      # TODO: should we handle parsing errors here?
      location = RGeo::Geographic.spherical_factory.point(params[:lng], params[:lat])

      @places = data_set.places_near(location, max_distance, params[:limit])
    else
      @places = data_set.places
    end

    respond_with(@places) do |format|
      format.json do
        render json: { status: "ok", contents: "places", places: @places.map(&:api_safe_hash) }
      end
    end
  rescue AmbiguousPostcodeError => e
    respond_to do |format|
      format.json do
        render json: { status: "address-information-required", contents: "addresses", addresses: e.addresses }
      end
    end
  end

protected

  def error_400_invalid_postcode
    render status: :bad_request, json: { error: "invalidPostcodeError" }
  end

  def error_400_valid_postcode
    render status: :bad_request, json: { error: "validPostcodeNoLocation" }
  end

  def select_data_set(service, version = nil)
    if user_signed_in? && version.present?
      service.data_sets.find(version)
    else
      service.active_data_set
    end
  end
end
