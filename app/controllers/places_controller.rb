class PlacesController < ApplicationController
  respond_to :json
  
  def show
    location = [params[:lat].to_f, params[:lng].to_f]
    args = params[:max_distance] ? { :max_distance => params[:max_distance].to_f } : {}
    limit = params[:limit] ? params[:limit].to_f : 100
    
    @places = Place.limit(limit).geo_near(location, args)
    respond_with(@places)
  end
end
