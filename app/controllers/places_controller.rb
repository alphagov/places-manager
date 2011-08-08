class PlacesController < ApplicationController
  respond_to :json, :kml
  
  def show
    @service = Service.where(slug: params[:id]).first
    head 404 and return if @service.nil? or @service.active_data_set.nil?
    
    if params[:max_distance]
      args = { :max_distance => params[:max_distance].to_f }
    elsif params[:limit]
      args = { :limit => params[:limit] }
    else
      args = { :limit => 50 }
    end

    @places = @service.active_data_set.places_near(params[:lat].to_f, params[:lng].to_f, args)
    respond_with(@places)
  end
end
