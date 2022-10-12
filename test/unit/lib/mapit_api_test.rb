require "test_helper"
require "mapit_api"
require "gds_api/test_helpers/mapit"

class MockResponse
  attr_reader :code, :to_hash

  def initialize(code, data)
    @code = code
    @to_hash = data
  end
end

class MapitApiTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Mapit

  context "extract_snac_from_mapit_response" do
    context "when asked to extract a district snac code" do
      MapitApi::DISTRICT_TYPES.each do |district_type|
        should "return the ons code of the first area with a type of #{district_type}" do
          location_data = GdsApi::Mapit::Location.new(
            "areas" => {
              "1" => { "codes" => { "ons" => "do-not-pick-me" }, "type" => "WMC" },
              "2" => { "codes" => { "ons" => "pick-me" }, "type" => district_type },
              "3" => { "codes" => { "ons" => "do-not-pick-me" }, "type" => "DIS" },
            },
          )

          assert_equal "pick-me", MapitApi.extract_snac_from_mapit_response(location_data, "district")
        end
      end

      should "not return the ons code of an area with a type of CTY" do
        location_data = GdsApi::Mapit::Location.new(
          "areas" => {
            "1" => { "codes" => { "ons" => "do-not-pick-me" }, "type" => "CTY" },
          },
        )

        assert_nil MapitApi.extract_snac_from_mapit_response(location_data, "district")
      end

      should "return nil if no area types match" do
        location_data = GdsApi::Mapit::Location.new("areas" => [])

        assert_nil MapitApi.extract_snac_from_mapit_response(location_data, "district")
      end
    end

    context "when asked to extract a county snac code" do
      MapitApi::COUNTY_TYPES.each do |county_type|
        should "return the ons code of the first area with a type of #{county_type}" do
          location_data = GdsApi::Mapit::Location.new(
            "areas" => {
              "1" => { "codes" => { "ons" => "do-not-pick-me" }, "type" => "WMC" },
              "2" => { "codes" => { "ons" => "pick-me" }, "type" => county_type },
              "3" => { "codes" => { "ons" => "do-not-pick-me" }, "type" => "CTY" },
            },
          )

          assert_equal "pick-me", MapitApi.extract_snac_from_mapit_response(location_data, "county")
        end
      end

      should "not return the ons code of an area with a type of DIS" do
        location_data = GdsApi::Mapit::Location.new(
          "areas" => {
            "1" => { "codes" => { "ons" => "do-not-pick-me" }, "type" => "DIS" },
          },
        )

        assert_nil MapitApi.extract_snac_from_mapit_response(location_data, "county")
      end

      should "return nil if no area types match" do
        location_data = GdsApi::Mapit::Location.new("areas" => [])

        assert_nil MapitApi.extract_snac_from_mapit_response(location_data, "county")
      end
    end

    context "when asked to extract any other type of snac code" do
      should "raise a InvalidLocationHierarchyType exception" do
        assert_raises(MapitApi::InvalidLocationHierarchyType) do
          MapitApi.extract_snac_from_mapit_response(GdsApi::Mapit::Location.new("areas" => []), "super output area")
        end
      end
    end
  end

  context "valid_post_code_no_location" do
    should "raise ValidPostcodeNoLocation for a valid postcode with no location" do
      stub_mapit_postcode_response_from_fixture("JE4 5TP")

      assert_raises(MapitApi::ValidPostcodeNoLocation) { MapitApi.location_for_postcode("JE4 5TP") }
    end
  end
end
