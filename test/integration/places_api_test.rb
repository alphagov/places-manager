require_relative '../integration_test_helper'
require 'csv'

class PlacesAPITest < ActionDispatch::IntegrationTest

  context "Requesting the full dataset" do
    setup do
      @service = FactoryGirl.create(:service)
      @data_set_1 = @service.active_data_set
      @data_set_2 = @service.data_sets.create()
      @place1_1 = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set_1.version,
                  location: Point.new(latitude: 51.613314, longitude: -0.158278), name: "Town Hall")
      @place1_2 = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set_1.version,
                  location: Point.new(latitude: 51.500728, longitude: -0.124626), name: "Palace of Westminster")
      @place2_1 = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set_2.version,
                  location: Point.new(latitude: 51.613314, longitude: -0.158278), name: "Town Hall 2")
      @place2_2 = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set_2.version,
                  location: Point.new(latitude: 51.500728, longitude: -0.124626), name: "Palace of Westminster 2")
      @data_set_2.activate
    end

    should "return all places for the current dataset as JSON" do
      get "/places/#{@service.slug}.json"

      assert_equal "application/json; charset=utf-8", last_response.content_type

      data = JSON.parse(last_response.body)
      assert_equal ['Palace of Westminster 2', 'Town Hall 2'], data.map {|p| p["name"] }
    end

    should "return all places as CSV" do
      get "/places/#{@service.slug}.csv"

      assert_equal "text/csv", last_response.content_type

      data = CSV.new(last_response.body, headers: true).read
      assert_equal ['Palace of Westminster 2', 'Town Hall 2'], data.map {|p| p["name"] }
    end

    should "return all places as KML" do
      get "/places/#{@service.slug}.kml"

      assert_equal "application/vnd.google-earth.kml+xml; charset=utf-8", last_response.content_type

      data = Nokogiri::XML.parse(last_response.body)
      names = data.xpath("//xmlns:Placemark/xmlns:name").map(&:text)
      assert_equal ['Palace of Westminster 2', 'Town Hall 2'], names
    end

    context "requesting a specific version" do
      should "return requested version when logged in" do
        GDS::SSO.test_user = FactoryGirl.create(:user)
        visit "/admin" # necessary to setup the login session

        visit "/places/#{@service.slug}.json?version=#{@data_set_1.to_param}"

        data = JSON.parse(page.source)
        assert_equal ['Palace of Westminster', 'Town Hall'], data.map {|p| p["name"] }
      end

      should "ignore requested version and return active version when not logged in" do
        visit "/places/#{@service.slug}.json?version=#{@data_set_1.to_param}"

        data = JSON.parse(page.source)
        # Titles from @data_set_2
        assert_equal ['Palace of Westminster 2', 'Town Hall 2'], data.map {|p| p["name"] }
      end
    end
  end

  context "Filtering places by location" do
    context "for a geo-distance service" do
      setup do
        @service = FactoryGirl.create(:service)
        @place1 = FactoryGirl.create(:place, service_slug: @service.slug,
                  location: Point.new(latitude: 51.613314, longitude: -0.158278), name: "Town Hall")
        @place2 = FactoryGirl.create(:place, service_slug: @service.slug,
                  location: Point.new(latitude: 51.500728, longitude: -0.124626), name: "Palace of Westminster")
      end

      should "return places near the given postcode" do
        stub_mapit_postcode_response_from_fixture("N11 3HD")
        stub_mapit_postcode_response_from_fixture("WC2B 6NH")

        get "/places/#{@service.slug}.json?postcode=N11+3HD"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place1.name, data[0]['name']

        get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place2.name, data[0]['name']
      end

      should "return places near the given lat/lng" do
        get "/places/#{@service.slug}.json?lat=51.617&lng=-0.149"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place1.name, data[0]['name']

        get "/places/#{@service.slug}.json?lat=51.517&lng=-0.120"
        data = JSON.parse(last_response.body)
        assert_equal 2, data.length
        assert_equal @place2.name, data[0]['name']
      end

      should "return a 400 for an invalid postcode" do
        GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('N11 3QQ').returns(nil)

        get "/places/#{@service.slug}.json?postcode=N11+3QQ"
        assert_equal 400, last_response.status
      end
    end


    context "for an authority-bounded service" do
      setup do
        @service = FactoryGirl.create(:service, :location_match_type => 'local_authority')
        @place1 = FactoryGirl.create(:place, service_slug: @service.slug, snac: "18UK",
                  location: Point.new(latitude: 51.0519276, longitude: -4.1907002), name: "John's Of Appledore")
        @place2 = FactoryGirl.create(:place, service_slug: @service.slug, snac: "00AG",
                  location: Point.new(latitude: 51.500728, longitude: -0.124626), name: "Palace of Westminster")
      end

      should "return the place(s) for the authority corresponding to the postcode" do
        stub_mapit_postcode_response_from_fixture("EX39 1QS")
        stub_mapit_postcode_response_from_fixture("WC2B 6NH")

        get "/places/#{@service.slug}.json?postcode=EX39+1QS"
        data = JSON.parse(last_response.body)
        assert_equal 1, data.length
        assert_equal @place1.name, data[0]['name']

        get "/places/#{@service.slug}.json?postcode=WC2B+6NH"
        data = JSON.parse(last_response.body)
        assert_equal 1, data.length
        assert_equal @place2.name, data[0]['name']
      end

      should "return empty array if there are no places in the corresponding authority" do
        stub_mapit_postcode_response_from_fixture("N11 3HD")

        get "/places/#{@service.slug}.json?postcode=N11+3HD"
        data = JSON.parse(last_response.body)
        assert_equal [], data
      end

      should "return a 400 for an invalid postcode" do
        GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('N11 3QQ').returns(nil)

        get "/places/#{@service.slug}.json?postcode=N11+3QQ"
        assert_equal 400, last_response.status
      end
    end
  end
end
