require_relative '../integration_test_helper'

class AreasByPostcodeTest < ActionDispatch::IntegrationTest
  setup do
    mapit_areas_response = OpenStruct.new(:code => 200, :to_hash => {
      "areas" => {
        44 => { "id" => 44, "name" => "Westminster City Council", "country_name" => "England", "type" => "LBO" },
        223 => { "id" => 223, "name" => "London", "country_name" => "England", "type" => "EUR" }
      }
    })
    mapit_location_response = OpenStruct.new(:response => mapit_areas_response)
    Imminence.mapit_api.stubs(:location_for_postcode).returns(mapit_location_response)
  end
  test "areas are returned for valid types" do
    visit "/areas/WC2B%206SE.json"

    parsed_response = JSON.parse(page.source)

    assert_equal "ok", parsed_response["_response_info"]["status"]
    assert_equal 2, parsed_response["total"]
    results = parsed_response["results"]

    assert_equal 44, results.first["id"]
    assert_equal "Westminster City Council", results.first["name"]
    assert_equal "England", results.first["country_name"]
    assert_equal "LBO", results.first["type"]
    assert_equal 223, results.last["id"]
    assert_equal "London", results.last["name"]
    assert_equal "England", results.last["country_name"]
    assert_equal "EUR", results.last["type"]
  end
end

