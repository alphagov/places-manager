require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  test "a new place is flagged as needing geocoding" do
    s = Service.create! slug: "chickens", name: "Chickens!"
    data_set = s.data_sets.create! version: 2
    p = Place.create!(
      service_slug: "chickens",
      data_set_version: 2,
      name: 'Hercules House',
      address1: '1 Hercules Road',
      town: 'London',
      postcode: 'SE1 7DU',
      source_address: "Bah"
    )

    assert Place.needs_geocoding.to_a.include?(p), "Not flagged as needing geocoding"
  end

  test "responds to full_address with a compiled address" do
    p = Place.new(:name => 'Hercules House', :address1 => '1 Hercules Road', :town => 'London', :postcode => 'SE1 7DU')
    assert_equal '1 Hercules Road, London, SE1 7DU, UK', p.full_address
  end

  test "can import a longitude and latitude" do
    p = Place.new(lat: '51.501009611553926', lng: '-0.141587067110009')
    p.reconcile_location

    assert_equal 51.501009611553926, p.lat
    assert_equal -0.141587067110009, p.lng
  end

  test "can create a Point" do
    point = Point.new(latitude: 56.2, longitude: -1.0)
    assert_equal 56.2, point.latitude
    assert_equal -1.0, point.longitude
  end

  test "require both coordinates for a point" do
    assert_raises ArgumentError do Point.new(latitude: 12.5) end
    assert_raises ArgumentError do Point.new(longitude: 12.5) end
  end

  test "points can be compared for equality" do
    point_a, point_b = [[56, 0.1], [-20, 95]].map { |lat,lng|
      Point.new(latitude: lat, longitude: lng)
    }
    # Not using assert_equals or refute_equals as we're not testing for a value
    assert point_a == point_a
    assert point_b == point_b
    refute point_a == point_b
    refute point_b == point_a
  end

  test "equality checks return false for non-points" do
    point = Point.new(latitude: 56.2, longitude: -1.0)
    refute point == {"longitude" => -1.0, "latitude" => 56.2}
    refute point == 12
  end

  test "points serialise in the correct order" do
    point = Point.new(latitude: 56.2, longitude: -1.0)
    field = Place::PointField.new
    # Note that longitude is serialised first: hashes in Ruby 1.9 keep order
    expected = {"longitude" => -1.0, "latitude" => 56.2}
    assert_equal expected.to_a, field.serialize(point).to_a
  end

  test "points can be deserialised" do
    point = Point.new(latitude: 56.2, longitude: -1.0)
    field = Place::PointField.new
    serialized = {"longitude" => -1.0, "latitude" => 56.2}
    assert_equal point, field.deserialize(serialized)
  end

  test "points can be deserialized from arrays" do
    field = Place::PointField.new
    assert_equal(
      Point.new(longitude: 56.2, latitude: -12.5),
      field.deserialize([-12.5, 56.2])
    )
  end

  test "points deserialise as nil from empty arrays" do
    field = Place::PointField.new
    assert_nil field.deserialize([])
  end

  test "points deserialise nil values correctly" do
    assert_nil Place::PointField.new.deserialize(nil)
  end

  test "points serialize nil correctly" do
    assert_nil Place::PointField.new.serialize(nil)
  end

  test "can look up a data set from a place" do
    s = Service.create! slug: "chickens", name: "Chickens!"
    s.data_sets.create! version: 2

    p = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2
    )
    assert_equal s.data_sets[1], p.data_set
  end

  test "cannot be edited if the data set is active" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    data_set = service.data_sets.create! version: 2

    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2
    )

    data_set.activate!

    place.name = "Aviation House"

    assert !place.valid?
    assert place.errors.keys.include?(:base)
  end

  test "cannot be edited if the data set is inactive and not the latest version" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    first_data_set = service.data_sets.create! version: 2

    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2
    )

    second_data_set = service.data_sets.create! version: 3
    place.name = "Aviation House"

    assert !place.valid?
    assert place.errors.keys.include?(:base)
  end

  test "can be edited if the data set is active but the only changed fields are 'location' or 'geocode_error'" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    first_data_set = service.data_sets.create! version: 2

    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2
    )

    second_data_set = service.data_sets.create! version: 3
    place.lat = 51.517356
    place.lng = -0.120742
    place.geocode_error = "Error message"

    assert place.valid?
    assert place.save
  end

  test "updating postcode performs geocoding" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    data_set = service.data_sets.create! version: 2, active: false
    
    Geogov.stubs(:lat_lon_from_postcode).with("SE1 7DU")
      .returns(latitude: 51.498241853641055, longitude: -0.11354773400359928)
    Geogov.stubs(:lat_lon_from_postcode).with("SW1H 9NB")
      .returns(latitude: 51.4999569844724, longitude: -0.13193340292244346)
    
    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2
    )

    place.geocode
    
    assert_equal 51.498241853641055, place.location.latitude
    assert_equal -0.11354773400359928, place.location.longitude

    place.postcode = "SW1H 9NB"

    assert place.save

    assert_equal 51.4999569844724, place.location.latitude
    assert_equal -0.13193340292244346, place.location.longitude
  end
end
