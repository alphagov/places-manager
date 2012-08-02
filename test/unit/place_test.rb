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

  test "can be found near a point" do
    s = Service.create(name: 'A key service', slug: 'a-key-service')
    p = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'SW1A 1AA',
      source_address: 'Westminster',
      lat: '51.501009611553926', lng: '-0.141587067110009'
    )
    assert p.persisted?
    places = s.data_sets.last.places.near(location: [p.lat, p.lng])
    assert_equal p, places.first
  end

  test "can be found near a point in the right order" do
    s = Service.create(name: 'A key service', slug: 'a-key-service')
    p = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'SW1A 1AA',
      source_address: 'Westminster',
      lat: '51.501009611553926', lng: '-0.141587067110009'
    )
    p2 = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'EH99 1SP',
      source_address: 'Edinburgh, City of Edinburgh EH99 1SP UK',
      lat: '55.953152', lng: '-3.175499'
    )
    places = s.data_sets.last.places.near(location: [p.lat, p.lng])
    assert_equal [p, p2], places.to_a
  end

  # test "points can be restrained to within a given distance in miles" do
  #   assert false, "TBD"
  # end

  # test "results of distance searches can tell us their distance from origin in miles" do
  # end
end
