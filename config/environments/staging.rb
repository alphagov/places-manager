require File.expand_path('production.rb', File.dirname(__FILE__))

Imminence::Application.configure do
  config.action_controller.asset_host = 'staging.alphagov.co.uk:8080'
  config.action_mailer.smtp_settings = {:enable_starttls_auto => false}
  
  Geogov.configure do |g|
    g.provider_for :centre_of_country,             DracosGazetteer.new("http://gazetteer.alpha.gov.uk")
    g.provider_for :centre_of_district,            Mapit.new("http://mapit.alpha.gov.uk")
    g.provider_for :areas_for_stack_from_postcode, Mapit.new("http://mapit.alpha.gov.uk")
    g.provider_for :areas_for_stack_from_coords,   Mapit.new("http://mapit.alpha.gov.uk")
    g.provider_for :lat_lon_from_postcode,         Mapit.new("http://mapit.alpha.gov.uk")
  end
end