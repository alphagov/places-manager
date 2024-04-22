require "places_manager/file_verifier"
require "csv"

class Admin::ServicesController < InheritedResources::Base
  include Admin::Defaults
  include Admin::FileUpload
  include Admin::Permissions

  custom_actions resource: :data_set_history
  before_action :set_breadcrumbs

  def index
    @only_used = params[:only_used] == "true"
    @services = services_for_user(current_user).order(:name)
    @total_services = @services.count
    if @only_used
      lookup = GovukSiteLookupService.new
      @services = @services.select { |service| lookup.govuk_page?(service.slug) }
    end
  end

  def create
    prohibit_non_csv_uploads
    create! do |_success, failure|
      failure.html do
        map_model_errors(@service.errors)
        return render "new"
      end
    end
    flash[:success] = "Service created"
  end

  def edit
    @service = Service.find(params[:id])
    check_permission!
  end

  def show
    @service = Service.find(params[:id])
    @only_errors = params[:only_errors] == "true"
    check_permission!
  end

  def update
    update! do |_success, failure|
      failure.html do
        map_model_errors(@service.errors)
        return render "edit"
      end
    end
    flash[:success] = "Service updated"
  end

  def map_model_errors(errors)
    @form_errors = errors.map { |e| { id: "service[#{e.attribute}]", text: "#{e.attribute.to_s.titleize} #{e.message}", href: "#service-#{e.attribute}-field" } }
  end

  def missing_csv
    @form_errors = [{ id: "service[data_file]", href: "#service-data-file-field", text: "You must upload an initial datafile." }]
    @service = Service.new(service_params)
    render "new", status: :unprocessable_entity
  end

  def bad_csv
    @form_errors = [{ id: "service[data_file]", href: "#service-data-file-field", text: "Could not process CSV file. Please check the format." }]
    @service = Service.new(service_params)
    render "new", status: :unprocessable_entity
  end

  def bad_encoding
    @form_errors = [{ id: "service[data_file]", href: "#service-data-file-field", text: "Could not process CSV file. Please check the format." }]
    @service = Service.new(service_params(correct_encoding: false))
    render "new", status: :unprocessable_entity
  end

protected

  def set_breadcrumbs
    @breadcrumbs = [{ title: "Services", url: "/" }]

    case params[:action]
    when "new"
      @breadcrumbs << { title: "New", url: new_resource_path }
    when "show"
      @breadcrumbs << { title: resource.name, url: resource_path(resource) }
    when "edit"
      @breadcrumbs << { title: resource.name, url: resource_path(resource) }
      @breadcrumbs << { title: "Edit", url: edit_resource_path(resource) }
    when "data_set_history"
      @breadcrumbs << { title: resource.name, url: resource_path(resource) }
      @breadcrumbs << { title: "Data Set History", url: edit_resource_path(resource) }
    end
  end

  def service_params(correct_encoding: true)
    permitted_params = %i[name slug source_of_data location_match_type local_authority_hierarchy_match_type]
    permitted_params << :data_file if correct_encoding && (%w[create new].include? action_name.to_s)
    gds_editor_slugs = org_slugs_from_params
    p = params
      .require(:service)
      .permit(*permitted_params)
    p = p.merge(organisation_slugs: [current_user.organisation_slug]) if org_slug_from_creator?
    p = p.merge(organisation_slugs: gds_editor_slugs) if gds_editor_slugs.any?
    p
  end

  def org_slugs_from_params
    return [] unless gds_editor?
    return [] unless params[:service]&.key?(:organisation_slugs)

    params[:service].delete(:organisation_slugs).split(/[, ]+/)
  end

  def org_slug_from_creator?
    !gds_editor? && @service.nil?
  end

  def services_for_user(user)
    return Service.all if gds_editor?

    Service.where(":organisation_slugs = ANY(organisation_slugs)", organisation_slugs: user.organisation_slug)
  end

  def check_permission!
    return if permission_for_service?(@service)

    raise PermissionDeniedException, "Sorry, you do not have permission to view this service."
  end
end
