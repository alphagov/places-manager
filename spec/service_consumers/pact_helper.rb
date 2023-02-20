ENV["PACT_DO_NOT_TRACK"] = "true"
ENV["RAILS_ENV"] = "test"

require "pact/provider/rspec"
require "webmock/rspec"
require "factory_bot_rails"
require "database_cleaner-active_record"
require "plek"
require "gds_api/test_helpers/local_links_manager"
require "gds_api/test_helpers/locations_api"

require ::File.expand_path("../../config/environment", __dir__)

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
  config.include FactoryBot::Syntax::Methods
  config.include GdsApi::TestHelpers::LocalLinksManager
  config.include GdsApi::TestHelpers::LocationsApi
end

WebMock.allow_net_connect!

DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner[:active_record].strategy = [:truncation, { except: %w[spatial_ref_sys] }]

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
      version_modifier = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-main'))}"

      pact_uri("#{base_url}/#{path}/#{version_modifier}")
    end
  end
end

Pact.provider_states_for "GDS API Adapters" do
  set_up do
    DatabaseCleaner.clean
    GDS::SSO.test_user = create(:user, permissions: %w[signin])
  end

  provider_state "a service exists called number-plate-supplier with places" do
    set_up do
      service = create(:service, slug: "number-plate-supplier")
      create(:place, service_slug: service.slug, latitude: 50.742754933617285, longitude: -1.9552618901330387)
    end
  end

  provider_state "a service exists called register office exists with places, and CH25 9BJ is a split postcode" do
    set_up do
      create(:service, slug: "register-office", location_match_type: "local_authority")
      stub_locations_api_has_location("CH25 9BJ", [
        { "address" => "House 1", "latitude" => 50, "longitude" => -1, "local_custodian_code" => 1 },
        { "address" => "House 2", "latitude" => 50, "longitude" => -1, "local_custodian_code" => 2 },
        { "address" => "House 3", "latitude" => 50, "longitude" => -1, "local_custodian_code" => 3 },
      ])
      stub_local_links_manager_has_a_local_authority("achester", local_custodian_code: 1)
      stub_local_links_manager_has_a_local_authority("beechester", local_custodian_code: 2)
      stub_local_links_manager_has_a_local_authority("ceechester", local_custodian_code: 3)
    end
  end
end
