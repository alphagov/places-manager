require 'gds_api/mapit'
require 'plek'

# In development, use MySociety's mapit install, as we won't normally have mapit running.
if Rails.env.development?
  Imminence.mapit_api = GdsApi::Mapit.new( ENV['MAPIT_ENDPOINT'] || 'http://mapit.mysociety.org/')
else
  Imminence.mapit_api = GdsApi::Mapit.new( Plek.current.find('mapit') )
end
