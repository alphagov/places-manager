require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  test "responds to full_address with a compiled address" do
    p = Place.new(:name => 'Hercules House', :address => '1 Hercules Road', :town => 'London', :postcode => 'SE1 7DU')
    assert_equal '1 Hercules Road, London, SE1 7DU, UK', p.full_address
  end
  
  test "can find distance from a given longitude/latitude" do
    p = Place.new(:location => [0,0])
    assert_equal 3454.9999999999995, p.distance_from(50, 0)
  end
end
