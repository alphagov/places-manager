require_relative "boot"

require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Imminence
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "London"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.generators do |g|
      g.orm :mongoid
      g.template_engine :erb # this could be :haml or whatever
      g.test_framework :test_unit, fixture: false # this could be :rpsec or whatever
    end

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil
  end
end

require "imminence"
