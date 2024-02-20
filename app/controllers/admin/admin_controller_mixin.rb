module Admin::AdminControllerMixin
  def self.included(base)
    base.send :include, GDS::SSO::ControllerMethods

    base.before_action :authenticate_user!
    base.send :defaults, route_prefix: "admin"
    base.helper_method :gds_editor?
    base.helper_method :org_name_for_current_user
  end

  def get_file_from_param(param)
    if param.respond_to?(:tempfile)
      param.tempfile
    else
      param
    end
  end

  def gds_editor?
    current_user.permissions.include?("GDS Editor")
  end

  def service_owner?(service)
    service.organisation_slugs.include?(current_user.organisation_slug)
  end

  def permission_for_service?(service)
    gds_editor? || service_owner?(service)
  end

  def org_name_for_current_user
    GdsApi.organisations.organisation(current_user.organisation_slug).to_hash["title"]
  rescue GdsApi::HTTPUnavailable
    current_user.organisation_slug
  end
end
