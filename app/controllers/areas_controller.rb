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
    api_response = Imminence.mapit_api.location_for_postcode(params[:postcode])
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
