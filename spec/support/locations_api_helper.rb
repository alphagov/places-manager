require "gds_api/test_helpers/locations_api"

def stub_locations_api_postcode_is_invalid(postcode)
  stub_request(:get, "#{GdsApi::TestHelpers::LocationsApi::LOCATIONS_API_ENDPOINT}/v1/locations?postcode=#{postcode}")
    .to_return(body: { "errors" => { "postcode" => ["This postcode is invalid"] } }.to_json, status: 400)
end

def stub_locations_api_does_not_have_a_postcode(postcode)
  stub_request(:get, "#{GdsApi::TestHelpers::LocationsApi::LOCATIONS_API_ENDPOINT}/v1/locations?postcode=#{postcode}")
    .to_return(body: { "errors" => { "postcode" => ["No results found for given postcode"] } }.to_json, status: 404)
end

def stub_locations_api_error(postcode)
  stub_request(:get, "#{GdsApi::TestHelpers::LocationsApi::LOCATIONS_API_ENDPOINT}/v1/locations?postcode=#{postcode}")
    .to_return(body: {}.to_json, status: 500)
end
