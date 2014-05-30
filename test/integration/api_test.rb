require 'test_helper'
require 'gds_api/imminence'

class ApiTest < ActionDispatch::IntegrationTest
  setup do
    @place1 = FactoryGirl.create(:place, location: Point.new(latitude: 51.613314, longitude: -0.158278), name: "Town Hall")
    @place2 = FactoryGirl.create(:place, location: Point.new(latitude: 51.500728, longitude: -0.124626), name: "Palace of Westminster")
  end

  test "Search by lat/long" do
    get "/places/#{@place1.service_slug}.json?lat=51.617&lng=-0.149"
    data = JSON.parse(last_response.body)
    assert_equal 2, data.length
    assert_equal @place1.name, data[0]['name']

    get "/places/#{@place1.service_slug}.json?lat=51.517&lng=-0.120"
    data = JSON.parse(last_response.body)
    assert_equal 2, data.length
    assert_equal @place2.name, data[0]['name']
  end

  test "Search by postcode" do
    GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('N11 3HD').returns(GdsApi::Mapit::Location.new('wgs84_lat' => 51.617, 'wgs84_lon' => -0.149))
    GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('WC2B 6NH').returns(GdsApi::Mapit::Location.new('wgs84_lat' => 51.517, 'wgs84_lon' => -0.120))

    get "/places/#{@place1.service_slug}.json?postcode=N11+3HD"
    data = JSON.parse(last_response.body)
    assert_equal 2, data.length
    assert_equal @place1.name, data[0]['name']

    get "/places/#{@place1.service_slug}.json?postcode=WC2B+6NH"
    data = JSON.parse(last_response.body)
    assert_equal 2, data.length
    assert_equal @place2.name, data[0]['name']
  end

  test "Search by invalid postcode" do
    GdsApi::Mapit.any_instance.expects(:location_for_postcode).with('N11 3QQ').returns(nil)

    get "/places/#{@place1.service_slug}.json?postcode=N11+3QQ"
    assert_equal 400, last_response.status
  end
end
