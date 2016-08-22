require_relative '../integration_test_helper'

class AreasByTypeTest < ActionDispatch::IntegrationTest
  setup do
    mapit_response = OpenStruct.new(code: 200, to_hash: {
      123 => { "id" => 123, "name" => "London", "country_name" => "England", "type" => "EUR" },
      234 => { "id" => 234, "name" => "Yorkshire and the Humber", "country_name" => "England", "type" => "EUR" },
      345 => { "id" => 345, "name" => "Scotland", "country_name" => "Scotland", "type" => "EUR" }
    })
    Imminence.mapit_api.stubs(:areas_for_type).returns(mapit_response)
  end

  test "areas are returned for valid types" do
    visit "/areas/EUR.json"

    parsed_response = JSON.parse(page.source)

    assert_equal "ok", parsed_response["_response_info"]["status"]
    assert_equal 3, parsed_response["total"]
    results = parsed_response["results"]

    assert results.none? { |r| r.key?("slug") }

    assert_equal "London", results.first["name"]
    assert_equal "England", results.first["country_name"]
    assert_equal "EUR", results.first["type"]
    assert_equal "Yorkshire and the Humber", results.second["name"]
    assert_equal "England", results.second["country_name"]
    assert_equal "EUR", results.second["type"]
    assert_equal "Scotland", results.last["name"]
    assert_equal "Scotland", results.last["country_name"]
    assert_equal "EUR", results.last["type"]
  end
end
