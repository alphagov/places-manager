require 'mapit_api/response_bridge'

class AreasController < ApplicationController
  def index
    api_response = Imminence.mapit_api.areas_for_type(params[:area_type])
    response_bridge = MapitApi::ResponseBridge.new(MapitApi::AreasByTypeResponse.new(api_response))
    @presenter = AreasPresenter.new(response_bridge)

    respond_to do |format|
      format.json { render :json => @presenter.present.to_json }
    end
  end

  def search
    api_response = Imminence.mapit_api.location_for_postcode(params[:postcode])
    puts "api_response #{api_response}"
    response_bridge = MapitApi::ResponseBridge.new(MapitApi::AreasByPostcodeResponse.new(api_response))
    @presenter = AreasPresenter.new(response_bridge)

    respond_to do |format|
      format.json { render :json => @presenter.present.to_json }
    end
  end
end
