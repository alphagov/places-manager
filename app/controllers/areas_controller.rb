class AreasController < ApplicationController
  def index
    api_response = Imminence.mapit_api.areas_for_type(params[:area_type])
    @presenter = AreasPresenter.new(api_response)
    respond_to do |format|
      format.json { render :json => @presenter.present.to_json }
    end
  end
end
