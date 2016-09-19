require_relative '../integration_test_helper'
require 'gds_api/test_helpers/mapit'

class AreasByPostcodeTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::Mapit

  setup do
    mapit_has_a_postcode_and_areas('WC2B 6SE', [51.516, -0.121], [
      { "name" => "Westminster City Council", "type" => "LBO" },
      { "name" => "London", "type" => "EUR" }
    ])
  end

  test "areas are returned for valid types" do
    visit "/areas/WC2B%206SE.json"

    parsed_response = JSON.parse(page.source)

    assert_equal "ok", parsed_response["_response_info"]["status"]
    assert_equal 2, parsed_response["total"]
    results = parsed_response["results"]

    assert results.none? { |r| r.key?("slug") }

    assert_equal "Westminster City Council", results.first["name"]
    assert_equal "LBO", results.first["type"]
    assert_equal "London", results.second["name"]
    assert_equal "EUR", results.second["type"]
  end
end
