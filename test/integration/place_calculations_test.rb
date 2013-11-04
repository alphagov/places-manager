require 'test_helper'

# These look like unit tests but they're testing our integration
# with MongoDB's geospatial indexing/querying so aren't strictly
# unit.
# They also don't feel right as Cucumber tests as they're not about
# the outward interface, but about how the pieces join together.
class PlaceCalculationsTest < ActionDispatch::IntegrationTest
  def setup_places
    s = Service.create(name: 'A key service', slug: 'a-key-service')
    buckingham_palace = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'SW1A 1AA',
      source_address: 'Buckingham Palace, Westminster',
      override_lat: '51.501009611553926', override_lng: '-0.141587067110009'
    )
    aviation_house = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'WC2B 6SE',
      source_address: 'Aviation House',
      override_lat: '51.516960431', override_lng: '-0.120586400134'
    )
    scottish_parliament = Place.create(
      service_slug: 'a-key-service',
      data_set_version: s.data_sets.last.version,
      postcode: 'EH99 1SP',
      source_address: 'Scottish Parliament',
      override_lat: '55.95439', override_lng: '-3.174706'
    )
    return s, buckingham_palace, aviation_house, scottish_parliament
  end

  test "can be found near a point in the right order" do
    service, buckingham_palace, aviation_house, scottish_parliament = setup_places
    places = service.data_sets.last.places_near buckingham_palace.location
    expected_places = [buckingham_palace, aviation_house, scottish_parliament]
    assert_equal expected_places, places.to_a

    # Check that the distances are reported correctly
    expected_distances_in_miles = [0, 1.82, 373]
    places.to_a.zip(expected_distances_in_miles).each do |place, expected_distance|
      assert_in_epsilon expected_distance, place.dis.in(:miles), 0.01
    end

  end

  test "points can be restrained to within a given distance in miles close by" do
    # These points are 1.4252962055598721 miles apart
    service, buckingham_palace, aviation_house, scottish_parliament = setup_places
    centre = buckingham_palace.location

    places = service.data_sets.last.places_near(centre, Distance.miles(1.42))
    assert_equal 1, places.length

    places = service.data_sets.last.places_near(centre, Distance.miles(1.83))
    assert_equal 2, places.length
  end

  test "points can be restrained to within a given distance in miles over a long distance" do
    # Buckingham Palace and the Scottish Parliament are approximately 331 miles apart
    service, buckingham_palace, aviation_house, scottish_parliament = setup_places
    centre = buckingham_palace.location

    places = service.data_sets.last.places_near(centre, Distance.miles(330))
    assert_equal 2, places.length

    places = service.data_sets.last.places_near(centre, Distance.miles(373))
    assert_equal 3, places.length
  end
end
