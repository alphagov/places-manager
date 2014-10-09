require 'integration_test_helper'

class PlacesAPITest < ActionDispatch::IntegrationTest

  context "Requesting the full dataset" do
    should "return all places as JSON"

    should "return all places as CSV"

    should "return all places as KML"

  end

  context "Filtering places by location" do
    context "for a geo-distance service" do
      setup do
        @service = FactoryGirl.create(:service)
        @place1 = FactoryGirl.create(:place, :service_slug => @service.slug,
                   :location => Point.new(:latitude => 51.613314, :longitude => -0.158278), :name => "Town Hall")
        @place2 = FactoryGirl.create(:place, :service_slug => @service.slug,
                   :location => Point.new(:latitude => 51.500728, :longitude => -0.124626), :name => "Palace of Westminster")
      end

      should "return places near the given postcode" do
        GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('N11 3HD').
          returns(GdsApi::Mapit::Location.new('wgs84_lat' => 51.617, 'wgs84_lon' => -0.149))
        GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('WC2B 6NH').
          returns(GdsApi::Mapit::Location.new('wgs84_lat' => 51.517, 'wgs84_lon' => -0.120))

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

      should "return the place(s) for the authority corresponding to the postcode"

      should "return a not-implemented error when attempting to search by lat/lng"

      should "return a 400 for an invalid postcode"
    end
  end
end
