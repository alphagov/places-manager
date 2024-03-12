require "imminence/file_verifier"
require "csv"

class Admin::ServicesController < InheritedResources::Base
  include Admin::AdminControllerMixin

  def index
    @services = services_for_user(current_user)
  end

  def create
    prohibit_non_csv_uploads
    create!
  rescue CSV::MalformedCSVError
    flash.now[:danger] = "Could not process CSV file. Please check the format."
    @service = Service.new(service_params)
    render action: "new"
  rescue InvalidCharacterEncodingError
    flash.now[:danger] = "Could not process CSV file. Please check the format."
    @service = Service.new(service_params(correct_encoding: false))
    render action: "new"
  end

  def edit
    @service = Service.find(params[:id])
    check_permission!
  end

  def show
    @service = Service.find(params[:id])
    check_permission!
  end

protected

  def prohibit_non_csv_uploads
    if params[:service][:data_file]
      file = get_file_from_param(params[:service][:data_file])
      fv = Imminence::FileVerifier.new(file)
      unless fv.csv?
        message = "Rejecting file with content type: #{fv.mime_type}"
        Rails.logger.info(message)
        params[:service].delete(:data_file)
        raise CSV::MalformedCSVError.new(message, 0)
      end
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
