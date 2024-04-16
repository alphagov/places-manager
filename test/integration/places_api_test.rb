require_relative "../integration_test_helper"
require "csv"
require "gds_api/test_helpers/local_links_manager"
require "gds_api/test_helpers/locations_api"

class PlacesAPITest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::LocalLinksManager
  include GdsApi::TestHelpers::LocationsApi

  context "Requesting the full data set" do
    setup do
      @service = FactoryBot.create(:service)
      @data_set1 = @service.active_data_set
      @data_set2 = @service.data_sets.create!
      @place_1a = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set1.version,
        latitude: 51.613314,
        longitude: -0.158278,
        name: "Town Hall",
      )
      @place_1b = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set1.version,
        latitude: 51.500728,
        longitude: -0.124626,
        name: "Palace of Westminster",
      )
      @place_2a = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set2.version,
        latitude: 51.613314,
        longitude: -0.158278,
        name: "Town Hall 2",
      )
      @place_2b = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set2.version,
        latitude: 51.500728,
        longitude: -0.124626,
        name: "Palace of Westminster 2",
      )
      @data_set2.activate
    end

    should "return all places for the current dataset as JSON" do
      get "/places/#{@service.slug}.json"

      assert_equal "application/json; charset=utf-8", last_response.content_type

      data = JSON.parse(last_response.body)
      assert_equal ["Palace of Westminster 2", "Town Hall 2"], (data["places"].map { |p| p["name"] })
    end

    should "return all places as CSV" do
      get "/places/#{@service.slug}.csv"

      assert_equal "text/csv", last_response.content_type

      data = CSV.new(last_response.body, headers: true).read
      assert_equal ["Palace of Westminster 2", "Town Hall 2"], (data.map { |p| p["name"] })
    end

    should "return all places as KML" do
      get "/places/#{@service.slug}.kml"

      assert_equal "application/vnd.google-earth.kml+xml; charset=utf-8", last_response.content_type

      data = Nokogiri::XML.parse(last_response.body)
      names = data.xpath("//xmlns:Placemark/xmlns:name").map(&:text)
      assert_equal ["Palace of Westminster 2", "Town Hall 2"], names
    end

    context "requesting a specific version" do
      setup do
        stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place").to_return(status: 200, body: { results: [] }.to_json, headers: {})
      end

      should "return requested version when logged in" do
        GDS::SSO.test_user = FactoryBot.create(:user)
        stub_organisations_test_department
        visit "/admin" # necessary to setup the login session

        visit "/places/#{@service.slug}.json?version=#{@data_set1.to_param}"

        data = JSON.parse(page.source)
        assert_equal ["Palace of Westminster", "Town Hall"], (data["places"].map { |p| p["name"] })
      end

      should "ignore requested version and return active version when not logged in" do
        visit "/places/#{@service.slug}.json?version=#{@data_set1.to_param}"

        data = JSON.parse(page.source)
        # Titles from @data_set2
        assert_equal ["Palace of Westminster 2", "Town Hall 2"], (data["places"].map { |p| p["name"] })
      end
    end
  end

  context "Filtering places by location" do
    context "for a geo-distance service" do
      setup do
        @service = FactoryBot.create(:service)
        @place1 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          latitude: 51.613314,
          longitude: -0.158278,
          name: "Town Hall",
        )
        @place2 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          latitude: 51.500728,
          longitude: -0.124626,
          name: "Palace of Westminster",
        )
      end

      should "return places near the given postcode" do
        stub_locations_api_has_location("N11 3HD", [{ "latitude" => 51.61727978727051, "longitude" => -0.14946662305980687 }])
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])

        get "/places/#{@service.slug}.json?postcode=N11+3HD"
        data = JSON.parse(last_response.body)
        assert_equal 2, data["places"].length
        assert_equal @place1.name, data["places"][0]["name"]

        get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
        data = JSON.parse(last_response.body)
        assert_equal 2, data["places"].length
        assert_equal @place2.name, data["places"][0]["name"]
      end

      should "return places near the given lat/lng" do
        get "/places/#{@service.slug}.json?lat=51.617&lng=-0.149"
        data = JSON.parse(last_response.body)
        assert_equal 2, data["places"].length
        assert_equal @place1.name, data["places"][0]["name"]

        get "/places/#{@service.slug}.json?lat=51.517&lng=-0.120"
        data = JSON.parse(last_response.body)
        assert_equal 2, data["places"].length
        assert_equal @place2.name, data["places"][0]["name"]
      end

      should "return a 400 for a missing postcode" do
        stub_locations_api_does_not_have_a_postcode("N11 3QQ")

        get "/places/#{@service.slug}.json?postcode=N11+3QQ"
        assert_equal 400, last_response.status
      end

      should "return a 400 for an invalid postcode" do
        stub_locations_api_does_not_have_a_postcode("N1")

        get "/places/#{@service.slug}.json?postcode=N1"
        assert_equal 400, last_response.status
      end
    end

    context "for an authority-bounded service" do
      setup do
        @service = FactoryBot.create(:service, location_match_type: "local_authority")
        @place1 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E12345678",
          latitude: 51.0519276,
          longitude: -4.1907002,
          name: "John's Of Appledore",
        )
        @place2 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E12345678",
          latitude: 51.053834,
          longitude: -4.191422,
          name: "Susie's Tea Rooms",
        )
        @place3 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E12345679",
          latitude: 51.500728,
          longitude: -0.124626,
          name: "Palace of Westminster",
        )
        @place4 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E12345679",
          latitude: 51.51837458322272,
          longitude: -0.12133586354538765,
          name: "FreeState Coffee",
        )
        @place5 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E12345680",
          latitude: 51.05420,
          longitude: -4.19096,
          name: "The Coffee Cabin",
        )
        @place6 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E12345680",
          latitude: 51.05289,
          longitude: -4.19111,
          name: "The Quay Restaurant and Gallery",
        )
        @place7 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E060000063",
          latitude: 51.05420,
          longitude: -4.19096,
          name: "Cumbrian Cabin",
        )
        @place8 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          gss: "E060000063",
          latitude: 51.05289,
          longitude: -4.19111,
          name: "Cumbrian Gallery",
        )
      end

      should "return empty array if there are no places in the corresponding authority" do
        stub_locations_api_has_location("N11 3HD", [{ "latitude" => 51.61727978727051, "longitude" => -0.14946662305980687, "local_custodian_code" => 1234 }])
        stub_local_links_manager_does_not_have_a_custodian_code(1234)

        get "/places/#{@service.slug}.json?postcode=N11+3HD"
        data = JSON.parse(last_response.body)
        assert_equal "ok", data["status"]
        assert_equal [], data["places"]
      end

      should "return a 400 for an invalid postcode" do
        stub_locations_api_does_not_have_a_postcode("N11 3QQ")

        get "/places/#{@service.slug}.json?postcode=N11+3QQ"
        assert_equal 400, last_response.status
      end

      context "when a postcode covers multiple authorities" do
        setup do
          stub_locations_api_has_location(
            "CH25 9BJ",
            [
              { "address" => "House 1", "local_custodian_code" => "1" },
              { "address" => "House 2", "local_custodian_code" => "2" },
              { "address" => "House 3", "local_custodian_code" => "3" },
            ],
          )
          stub_local_links_manager_has_a_local_authority("achester", local_custodian_code: 1, gss: "E12345678")
          stub_local_links_manager_has_a_local_authority("beechester", local_custodian_code: 2, gss: "E12345679")
          stub_local_links_manager_has_a_local_authority("ceechester", local_custodian_code: 3, gss: "E12345680")
          stub_local_links_manager_does_not_have_an_authority("deechester")
        end

        should "return an address array if the postcode exists in multiple authorities" do
          get "/places/#{@service.slug}.json?postcode=CH25+9BJ"
          data = JSON.parse(last_response.body)
          assert_equal "address-information-required", data["status"]
          assert_equal "addresses", data["contents"]
          assert_equal "House 1", data["addresses"][0]["address"]
          assert_equal "achester", data["addresses"][0]["local_authority_slug"]
          assert_equal 3, data["addresses"].count
        end

        should "returns only search results within an authority if the local_authority_slug is specified" do
          get "/places/#{@service.slug}.json?postcode=CH25+9BJ&local_authority_slug=beechester"
          data = JSON.parse(last_response.body)
          assert_equal "ok", data["status"]
          assert_equal "places", data["contents"]
          assert_equal 2, data["places"].count
          assert_equal "Palace of Westminster", data["places"][0]["name"]
          assert_equal "FreeState Coffee", data["places"][1]["name"]
        end

        should "returns 400 valid postcode if the local_authority_slug is specified but is not valid" do
          get "/places/#{@service.slug}.json?postcode=CH25+9BJ&local_authority_slug=deechester"
          data = JSON.parse(last_response.body)
          assert_equal 400, last_response.status
          assert_equal "validPostcodeNoLocation", data["error"]
        end
      end

      context "when the service is bounded to districts" do
        setup do
          @service.update(local_authority_hierarchy_match_type: Service::LOCAL_AUTHORITY_DISTRICT_MATCH)
        end

        should "return the district places in order of nearness, not the county ones for postcodes in a county+district council hierarchy" do
          stub_locations_api_has_location("EX39 1QS", [{ "latitude" => 51.05318361810428, "longitude" => -4.191071523498792, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_district_and_county_local_authority("my-district", "my-county", district_gss: "E12345678", county_gss: "E12345680", local_custodian_code: 1234)

          get "/places/#{@service.slug}.json?postcode=EX39+1QS"
          data = JSON.parse(last_response.body)
          assert_equal 2, data["places"].length
          assert_equal @place2.name, data["places"][0]["name"]
          assert_equal @place1.name, data["places"][1]["name"]
        end

        should "return all the places in order of nearness for postcodes not in a county+district council hierarchy" do
          stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_local_authority("county1", country_name: "England", gss: "E12345679", local_custodian_code: 1234)

          get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
          data = JSON.parse(last_response.body)
          assert_equal 2, data["places"].length
          assert_equal @place4.name, data["places"][0]["name"]
          assert_equal @place3.name, data["places"][1]["name"]
        end
      end

      context "when the service is bounded to counties" do
        setup do
          @service.update(local_authority_hierarchy_match_type: Service::LOCAL_AUTHORITY_COUNTY_MATCH)
        end

        should "only return the county results in order of nearness, not the district ones for postcodes in a county+district council hierarchy" do
          stub_locations_api_has_location("EX39 1QS", [{ "latitude" => 51.05318361810428, "longitude" => -4.191071523498792, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_district_and_county_local_authority("my-district", "my-county", district_gss: "E12345678", county_gss: "E12345680", local_custodian_code: 1234)

          get "/places/#{@service.slug}.json?postcode=EX39+1QS"
          data = JSON.parse(last_response.body)
          assert_equal 2, data["places"].length
          assert_equal @place6.name, data["places"][0]["name"]
          assert_equal @place5.name, data["places"][1]["name"]
        end

        should "return all the places in order of nearness for postcodes not in a county+district council hierarchy" do
          stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_local_authority("county1", country_name: "England", gss: "E12345679", local_custodian_code: 1234)

          get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
          data = JSON.parse(last_response.body)
          assert_equal 2, data["places"].length
          assert_equal @place4.name, data["places"][0]["name"]
          assert_equal @place3.name, data["places"][1]["name"]
        end
      end
    end
  end
end
