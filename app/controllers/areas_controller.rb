require "mapit_api"
require "gds_api/exceptions"

class AreasController < ApplicationController
  def search
    api_response = fetch_location_for_postcode(params[:postcode])
    response = MapitApi::AreasByPostcodeResponse.new(api_response)
    @presenter = AreasPresenter.new(response)

    respond_to do |format|
      format.json { render json: @presenter.present.to_json }
    end
  end

private

  def fetch_location_for_postcode(postcode)
    Imminence.mapit_api.location_for_postcode(postcode)
  rescue GdsApi::HTTPClientError
    nil
  end
end
