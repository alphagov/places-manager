require_relative "../integration_test_helper"
require "csv"

class PlacesAPITest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::Mapit

  context "Requesting the full dataset" do
    setup do
      @service = FactoryBot.create(:service)
      @data_set_1 = @service.active_data_set
      @data_set_2 = @service.data_sets.create
      @place_1a = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set_1.version,
        latitude: 51.613314,
        longitude: -0.158278,
        name: "Town Hall",
      )
      @place_1b = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set_1.version,
        latitude: 51.500728,
        longitude: -0.124626,
        name: "Palace of Westminster",
      )
      @place_2a = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set_2.version,
        latitude: 51.613314,
        longitude: -0.158278,
        name: "Town Hall 2",
      )
      @place_2b = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set_2.version,
        latitude: 51.500728,
        longitude: -0.124626,
        name: "Palace of Westminster 2",
      )
      @data_set_2.activate
    end

    should "return all places for the current dataset as JSON" do
      get "/places/#{@service.slug}.json"

      assert_equal "application/json; charset=utf-8", last_response.content_type

      data = JSON.parse(last_response.body)
      assert_equal ["Palace of Westminster 2", "Town Hall 2"], (data.map { |p| p["name"] })
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
      should "return requested version when logged in" do
        GDS::SSO.test_user = FactoryBot.create(:user)
        visit "/admin" # necessary to setup the login session

        visit "/places/#{@service.slug}.json?version=#{@data_set_1.to_param}"

        data = JSON.parse(page.source)
        assert_equal ["Palace of Westminster", "Town Hall"], (data.map { |p| p["name"] })
      end

      should "ignore requested version and return active version when not logged in" do
        visit "/places/#{@service.slug}.json?version=#{@data_set_1.to_param}"

        data = JSON.parse(page.source)
        # Titles from @data_set_2
        assert_equal ["Palace of Westminster 2", "Town Hall 2"], (data.map { |p| p["name"] })
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
        stub_mapit_postcode_response_from_fixture("N11 3HD")
        stub_mapit_postcode_response_from_fixture("WC2B 6NH")

        get "/places/#{@service.slug}.json?postcode=N11+3HD"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place1.name, data[0]["name"]

        get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place2.name, data[0]["name"]
      end

      should "return places near the given lat/lng" do
        get "/places/#{@service.slug}.json?lat=51.617&lng=-0.149"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place1.name, data[0]["name"]

        get "/places/#{@service.slug}.json?lat=51.517&lng=-0.120"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place2.name, data[0]["name"]
      end

      should "return a 400 for a missing postcode" do
        mapit_does_not_have_a_postcode("N11 3QQ")

        get "/places/#{@service.slug}.json?postcode=N11+3QQ"
        assert_equal 400, last_response.status
      end

      should "return a 400 for an invalid postcode" do
        mapit_does_not_have_a_bad_postcode("N1")

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
          snac: "18UK",
          latitude: 51.0519276,
          longitude: -4.1907002,
          name: "John's Of Appledore",
        )
        @place2 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "18UK",
          latitude: 51.053834,
          longitude: -4.191422,
          name: "Susie's Tea Rooms",
        )
        @place3 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "00AG",
          latitude: 51.500728,
          longitude: -0.124626,
          name: "Palace of Westminster",
        )
        @place4 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "00AG",
          latitude: 51.51837458322272,
          longitude: -0.12133586354538765,
          name: "FreeState Coffee",
        )
        @place5 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "18",
          latitude: 51.05420,
          longitude: -4.19096,
          name: "The Coffee Cabin",
        )
        @place6 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "18",
          latitude: 51.05289,
          longitude: -4.19111,
          name: "The Quay Restaurant and Gallery",
        )
      end

      should "return empty array if there are no places in the corresponding authority" do
        stub_mapit_postcode_response_from_fixture("N11 3HD")

        get "/places/#{@service.slug}.json?postcode=N11+3HD"
        data = JSON.parse(last_response.body)
        assert_equal [], data
      end

      should "return a 400 for an invalid postcode" do
        mapit_does_not_have_a_postcode("N11 3QQ")

        get "/places/#{@service.slug}.json?postcode=N11+3QQ"
        assert_equal 400, last_response.status
      end

      context "when the service is bounded to districts" do
        setup do
          @service.update(local_authority_hierarchy_match_type: Service::LOCAL_AUTHORITY_DISTRICT_MATCH)
        end

        should "return the district places in order of nearness, not the county ones for postcodes in a county+district council hierarchy" do
          stub_mapit_postcode_response_from_fixture("EX39 1QS")

          get "/places/#{@service.slug}.json?postcode=EX39+1QS"
          data = JSON.parse(last_response.body)
          assert_equal 2, data.length
          assert_equal @place2.name, data[0]["name"]
          assert_equal @place1.name, data[1]["name"]
        end

        should "return all the places in order of nearness for postcodes not in a county+district council hierarchy" do
          stub_mapit_postcode_response_from_fixture("WC2B 6NH")

          get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
          data = JSON.parse(last_response.body)
          assert_equal 2, data.length
          assert_equal @place4.name, data[0]["name"]
          assert_equal @place3.name, data[1]["name"]
        end
      end

      context "when the service is bounded to counties" do
        setup do
          @service.update(local_authority_hierarchy_match_type: Service::LOCAL_AUTHORITY_COUNTY_MATCH)
        end

        should "only return the county results in order of nearness, not the district ones for postcodes in a county+district council hierarchy" do
          stub_mapit_postcode_response_from_fixture("EX39 1QS")

          get "/places/#{@service.slug}.json?postcode=EX39+1QS"
          data = JSON.parse(last_response.body)
          assert_equal 2, data.length
          assert_equal @place6.name, data[0]["name"]
          assert_equal @place5.name, data[1]["name"]
        end

        should "return all the places in order of nearness for postcodes not in a county+district council hierarchy" do
          stub_mapit_postcode_response_from_fixture("WC2B 6NH")

          get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
          data = JSON.parse(last_response.body)
          assert_equal 2, data.length
          assert_equal @place4.name, data[0]["name"]
          assert_equal @place3.name, data[1]["name"]
        end
      end
    end
  end
end
