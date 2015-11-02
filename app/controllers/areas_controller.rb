require 'mapit_api'

class AreasController < ApplicationController
  def index
    api_response = Imminence.mapit_api.areas_for_type(params[:area_type])

    if regions_request?
      response = MapitApi::RegionsResponse.new(api_response)
    else
      response = MapitApi::AreasByTypeResponse.new(api_response)
    end

    @presenter = AreasPresenter.new(response)

    respond_to do |format|
      format.json { render json: @presenter.present.to_json }
    end
  end

  def search
    # Strip trailing whitespace, most non-alphanumerics, and use the
    # uk_postcode gem to potentially transpose O/0 and I/1.
    sanitized_postcode = UKPostcode.parse(params[:postcode].gsub(/[^\w\s]/i, '').strip).to_s

    api_response = Imminence.mapit_api.location_for_postcode(sanitized_postcode)
    response = MapitApi::AreasByPostcodeResponse.new(api_response)
    @presenter = AreasPresenter.new(response)

    respond_to do |format|
      format.json { render json: @presenter.present.to_json }
    end
  end

  private

  def regions_request?
    params[:area_type] == "EUR"
  end

end
