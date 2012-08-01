ActionController::Renderers.add :csv do |detailed_report, options|
  if detailed_report.first.is_a?(Place)
    filename = "#{detailed_report.first.data_set.service.slug}.csv"

    headers['Cache-Control']             = 'must-revalidate, post-check=0, pre-check=0'
    headers['Content-Disposition']       = "attachment; filename=#{filename}"
    headers['Content-Type']              = 'text/csv'
    headers['Content-Transfer-Encoding'] = 'binary'

    self.response_body = DataSetCsvPresenter.new(detailed_report.first.data_set).to_csv
  end
end

class PlacesController < ApplicationController
  respond_to :json, :kml, :csv

  def show
    @service = Service.where(slug: params[:id]).first
    head 404 and return if @service.nil? or @service.active_data_set.nil?

    if user_signed_in? and params[:version].present?
      data_set = @service.data_sets.find(params[:version])
    else
      data_set = @service.active_data_set
    end

    head 404 and return if data_set.nil?

    @places = Place.where(:service_slug => @service.slug, 
      :data_set_version => data_set.version)

    if params[:lat].present? && params[:lng].present?
      place_params = {"$near" => [params[:lat].to_f, params[:lng].to_f]}

      if params[:max_distance]
        place_params['$maxDistance'] => params[:max_distance].fdiv(111.12)
      end

      @places = @places.where(:location => place_params)
    end

    @places = @places.limit(params[:limit] || 50)

    respond_with(@places)
  end
end
