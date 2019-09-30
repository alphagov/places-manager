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

  context "district_snac_for_postcode" do
    should "return the snac for a district council(DIS)" do
      stub_mapit_postcode_response_from_fixture("EX39 1QS")

      assert_equal "18UK", MapitApi.district_snac_for_postcode("EX39 1QS")
    end

    should "return the snac for a london borough(LBO)" do
      stub_mapit_postcode_response_from_fixture("WC2B 6NH")

      assert_equal "00AG", MapitApi.district_snac_for_postcode("WC2B 6NH")
    end

    should "return the snac for a metropolitan district(MTD)" do
      stub_mapit_postcode_response_from_fixture("M2 5DB")

      assert_equal "00BN", MapitApi.district_snac_for_postcode("M2 5DB")
    end

    should "return the snac for a unitary authority(UTA)" do
      stub_mapit_postcode_response_from_fixture("EH15 1AF")

      assert_equal "00QP", MapitApi.district_snac_for_postcode("EH15 1AF")
    end

    should "return the snac for a Isles of Scilly parish(COP)" do
      stub_mapit_postcode_response_from_fixture("TR21 0LW")

      assert_equal "00HF", MapitApi.district_snac_for_postcode("TR21 0LW")
    end

    should "return nil if mapit doesn't return a district area type" do
      stub_mapit_postcode_response_from_fixture("BT1 5GS")

      assert_nil MapitApi.district_snac_for_postcode("BT1 5GS")
    end

    should "raise InvalidPostcodeError for a missing postcode" do
      mapit_does_not_have_a_postcode("AB1 2CD")

      assert_raises(MapitApi::InvalidPostcodeError) { MapitApi.district_snac_for_postcode("AB1 2CD") }
    end
  end

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

  context "payload" do
    setup do
      @areas = {
        123 => { "id" => 123, "name" => "Westminster City Council", "country_name" => "England", "type" => "LBO" },
        234 => { "id" => 234, "name" => "London", "country_name" => "England", "type" => "EUR" },
      }
    end
    context "for an AreasByTypeResponse" do
      should "return code and areas attributes in a hash" do
        api_response = MockResponse.new(200, @areas)
        response = MapitApi::AreasByTypeResponse.new(api_response)

        assert_equal 200, response.payload[:code]
        assert_equal 123, response.payload[:areas].first["id"]
        assert_equal "Westminster City Council", response.payload[:areas].first["name"]
        assert_equal 234, response.payload[:areas].last["id"]
        assert_equal "London", response.payload[:areas].last["name"]
      end

      should "return a 404 code and no areas if no area types are found" do
        response = MapitApi::AreasByTypeResponse.new(nil)

        assert_equal 404, response.payload[:code]
        assert_equal [], response.payload[:areas]
      end
    end

    context "for an AreasByPostcodeResponse" do
      should "return code and areas attributes in a hash" do
        location = OpenStruct.new(response: MockResponse.new(200, "areas" => @areas))
        response = MapitApi::AreasByPostcodeResponse.new(location)

        assert_equal 200, response.payload[:code]
        assert_equal 123, response.payload[:areas].first["id"]
        assert_equal "Westminster City Council", response.payload[:areas].first["name"]
        assert_equal 234, response.payload[:areas].last["id"]
        assert_equal "London", response.payload[:areas].last["name"]
      end

      should "return a 404 code and no areas if no location is found" do
        response = MapitApi::AreasByPostcodeResponse.new(nil)

        assert_equal 404, response.payload[:code]
        assert_equal [], response.payload[:areas]
      end
    end
  end
end
