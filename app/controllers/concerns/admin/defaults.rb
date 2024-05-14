require "active_support/concern"

module Admin
  module Defaults
    extend ActiveSupport::Concern

    included do
      defaults route_prefix: "admin"
    end
  end
end
