require "active_support/concern"

module Admin
  module Defaults
    extend ActiveSupport::Concern

    included do
      defaults route_prefix: "admin"

      before_action :redirect_if_old_hostname
    end

    OLD_HOSTNAME = "imminence".freeze
    NEW_HOSTNAME = "places-manager".freeze

    def redirect_if_old_hostname
      redirect_to(request.url.gsub(OLD_HOSTNAME, NEW_HOSTNAME), allow_other_host: true) if request.host.include?(OLD_HOSTNAME)
    end
  end
end
