class ApplicationController < ActionController::Base
  protect_from_forgery

  include GDS::SSO::ControllerMethods

  if Rails.env.test?
    before_filter do
      headers["X-Slimmer-Skip"] = "absolutely"
    end
  end
end
