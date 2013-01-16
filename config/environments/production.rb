Imminence::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable even limited exception/debug pages in production for two reasons:
  #  1) our backend rails apps get X-Forwarded-For & Client-IP for all requests
  #     as 10.x.x.x, which is a trusted proxy. This means they render the
  #     limited exception/debug pages.
  #  2) our backend rails apps receive requests from other apps that might
  #     appear to be on trusted proxy IPs, so we might render exception/debug
  #     page, which could then be exposed in a frontend app to the world.
  config.action_dispatch.show_exceptions = false
  
  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => Plek.current.find('imminence') }
  config.action_mailer.delivery_method = :ses

  Geogov.configure do |g|
    g.provider_for :centre_of_country,             Geogov::Geonames.new
    g.provider_for :centre_of_district,            Geogov::Mapit.new("http://mapit.production.alphagov.co.uk")
    g.provider_for :areas_for_stack_from_postcode, Geogov::Mapit.new("http://mapit.production.alphagov.co.uk")
    g.provider_for :areas_for_stack_from_coords,   Geogov::Mapit.new("http://mapit.production.alphagov.co.uk")
    g.provider_for :lat_lon_from_postcode,         Geogov::Mapit.new("http://mapit.production.alphagov.co.uk")
  end

  config.lograge.enabled = true
end
