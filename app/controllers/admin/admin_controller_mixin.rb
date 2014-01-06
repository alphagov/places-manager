module Admin::AdminControllerMixin
  def self.included(base)
    base.send :include, GDS::SSO::ControllerMethods

    base.before_filter :authenticate_user!
    base.before_filter :require_signin_permission!
    base.send :defaults, :route_prefix => 'admin'
  end

  def get_file_from_param(param)
    if param.respond_to?(:tempfile)
      param.tempfile
    else
      param
    end
  end
end

class InvalidUploadError < Exception; end
