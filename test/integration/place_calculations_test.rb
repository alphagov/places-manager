require 'test_helper'

# These look like unit tests but they're testing our integration
# with MongoDB's geospatial indexing/querying so aren't strictly
# unit.
# They also don't feel right as Cucumber tests as they're not about
# the outward interface, but about how the pieces join together.
class PlaceCalculationsTest < ActiveSupport::TestCase
  def setup_places
    s = Service.create(name: 'A key service', slug: 'a-key-service')
    buckingham_palace = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'SW1A 1AA',
      source_address: 'Buckingham Palace, Westminster',
      lat: '51.501009611553926', lng: '-0.141587067110009'
    )
    aviation_house = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'WC2B 6SE',
      source_address: 'Aviation House',
      lat: '51.516960431', lng: '-0.120586400134'
    )
    scottish_parliament = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'EH99 1SP',
      source_address: 'Scottish Parliament',
      lat: '55.95439', lng: '-3.174706'
    )
    return s, buckingham_palace, aviation_house, scottish_parliament
  end

  test "can be found near a point in the right order" do
    service, p1, p2 = setup_places
    places = service.data_sets.last.places_near([p1.lat, p1.lng])
    assert_equal [p1, p2], places.to_a
  end

  test "points can be restrained to within a given distance in miles close by" do
    # These points are 1.4252962055598721 miles apart
    service, buckingham_palace, aviation_house, scottish_parliament = setup_places
    coords = {latitude: buckingham_palace.lat, longitude: buckingham_palace.lng}

    places = service.data_sets.last.places_near(coords, [1.42, :miles])
    assert_equal 1, places.length

    places = service.data_sets.last.places_near(coords, [1.43, :miles])
    assert_equal 2, places.length
  end

  test "points can be restrained to within a given distance in miles over a long distance" do
    # Buckingham Palace and the Scottish Parliament are approximately 331 miles apart
    service, buckingham_palace, aviation_house, scottish_parliament = setup_places
    coords = {latitude: buckingham_palace.lat, longitude: buckingham_palace.lng}

    places = service.data_sets.last.places_near(coords, [330, :miles])
    assert_equal 2, places.length

    places = service.data_sets.last.places_near(coords, [335, :miles])
    assert_equal 3, places.length
  end
end
