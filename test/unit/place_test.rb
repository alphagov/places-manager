require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  test "responds to full_address with a compiled address" do
    p = Place.new(:name => 'Hercules House', :address1 => '1 Hercules Road', :town => 'London', :postcode => 'SE1 7DU')
    assert_equal '1 Hercules Road, London, SE1 7DU, UK', p.full_address
  end
  
  test "can find distance from a given longitude/latitude" do
    p = Place.new(:location => [0,0])
    assert_equal 3454.9999999999995, p.distance_from(50, 0)
  end

  test "can import a longitude and latitude" do
    p = Place.new(lat: '51.501009611553926', lng: '-0.141587067110009')
    p.reconcile_location

    assert_equal 51.501009611553926, p.lat
    assert_equal -0.141587067110009, p.lng
  end
end
