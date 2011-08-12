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
    
    if user_signed_in? and params[:version].present?
      data_set = @service.data_sets.find(id: params[:version])
    else
      data_set = @service.active_data_set
    end
    
    head 404 and return if data_set.nil?

    if params[:lat].present?
      @places = data_set.places_near(params[:lat].to_f, params[:lng].to_f, args)
    else
      @places = data_set.places.all
    end

    respond_with(@places)
  end
end
