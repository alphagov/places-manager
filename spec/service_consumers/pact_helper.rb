require "pact/provider/rspec"
require "webmock/rspec"
require "factory_bot_rails"
require "database_cleaner"

require ::File.expand_path("../../config/environment", __dir__)

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
  config.include FactoryBot::Syntax::Methods
end

WebMock.allow_net_connect!

MAPIT_ENDPOINT = Plek.current.find("mapit")

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
    DatabaseCleaner.clean_with :truncation
    GDS::SSO.test_user = create(:user, permissions: %w[signin])
  end

  provider_state "a service exists called number-plate-supplier with places" do
    set_up do
      service = create(:service, slug: "number-plate-supplier")
      create(:place, service_slug: service.slug, latitude: 50.742754933617285, longitude: -1.9552618901330387)
    end
  end

  provider_state "a place exists with a postcode and areas" do
    set_up do
      service = create(:service, slug: "local-authority")
      create(:place, service_slug: service.slug, postcode: "WC2B 6SE")

      areas = [
        { "name" => "Westminster City Council", "type" => "LBO" },
        { "name" => "London", "type" => "EUR" },
      ]

      response = {
        "wgs84_lat" => 51.516,
        "wgs84_lon" => -0.121,
        "postcode" => "WC2B 6SE",
      }

      area_response = Hash[areas.map.with_index do |area, i|
        [i,
         {
           "codes" => {
             "ons" => area["ons"],
             "gss" => area["gss"],
             "govuk_slug" => area["govuk_slug"],
           },
           "name" => area["name"],
           "type" => area["type"],
           "country_name" => area["country_name"],
         }]
      end]

      postcode = "WC2B 6SE"

      stub_request(:get, "#{MAPIT_ENDPOINT}/postcode/#{postcode.tr(' ', '+')}.json")
        .to_return(body: response.merge("areas" => area_response).to_json, status: 200)
      stub_request(:get, "#{MAPIT_ENDPOINT}/postcode/partial/#{postcode.split(' ').first}.json")
        .to_return(body: response.to_json, status: 200)
    end
  end
end
