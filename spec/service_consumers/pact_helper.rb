require "pact/provider/rspec"
require "webmock/rspec"
require "factory_bot_rails"
require "database_cleaner-mongoid"

require ::File.expand_path("../../config/environment", __dir__)

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
  config.include FactoryBot::Syntax::Methods
end

WebMock.allow_net_connect!

MAPIT_ENDPOINT = Plek.new.find("mapit")

def url_encode(str)
  ERB::Util.url_encode(str)
end

Pact.service_provider "Imminence API" do
  honours_pact_with "GDS API Adapters" do
    if ENV["PACT_URI"]
      pact_uri(ENV["PACT_URI"])
    else
      base_url = "https://pact-broker.cloudapps.digital"
      path = "pacts/provider/#{url_encode(name)}/consumer/#{url_encode(consumer_name)}"
      version_modifier = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-master'))}"

      pact_uri("#{base_url}/#{path}/#{version_modifier}")
    end
  end
end

Pact.provider_states_for "GDS API Adapters" do
  set_up do
    DatabaseCleaner.clean_with :deletion
    GDS::SSO.test_user = create(:user, permissions: %w[signin])
  end

  provider_state "a service exists called number-plate-supplier with places" do
    set_up do
      service = create(:service, slug: "number-plate-supplier")
      create(:place, service_slug: service.slug, latitude: 50.742754933617285, longitude: -1.9552618901330387)
    end
  end
end
