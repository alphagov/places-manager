require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
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
    point = Place::Point.new(latitude: 56.2, longitude: -1.0)
    assert_equal 56.2, point.latitude
    assert_equal -1.0, point.longitude
  end

  test "require both coordinates for a point" do
    assert_raises ArgumentError do Place::Point.new(latitude: 12.5) end
    assert_raises ArgumentError do Place::Point.new(longitude: 12.5) end
  end

  test "points can be compared for equality" do
    point_a, point_b = [[56, 0.1], [-20, 95]].map { |lat,lng|
      Place::Point.new(latitude: lat, longitude: lng)
    }
    # Not using assert_equals or refute_equals as we're not testing for a value
    assert point_a == point_a
    assert point_b == point_b
    refute point_a == point_b
    refute point_b == point_a
  end

  test "equality checks return false for non-points" do
    point = Place::Point.new(latitude: 56.2, longitude: -1.0)
    refute point == {"longitude" => -1.0, "latitude" => 56.2}
    refute point == 12
  end

  test "points serialise in the correct order" do
    point = Place::Point.new(latitude: 56.2, longitude: -1.0)
    field = Place::Point::Field.new
    # Note that longitude is serialised first: hashes in Ruby 1.9 keep order
    expected = {"longitude" => -1.0, "latitude" => 56.2}
    assert_equal expected.to_a, field.serialize(point).to_a
  end

  test "points can be deserialised" do
    point = Place::Point.new(latitude: 56.2, longitude: -1.0)
    field = Place::Point::Field.new
    serialized = {"longitude" => -1.0, "latitude" => 56.2}
    assert_equal point, field.deserialize(serialized)
  end

  test "points can be deserialized from arrays" do
    field = Place::Point::Field.new
    assert_equal(
      Place::Point.new(longitude: 56.2, latitude: -12.5),
      field.deserialize([-12.5, 56.2])
    )
  end

  test "points deserialise as nil from empty arrays" do
    field = Place::Point::Field.new
    assert_nil field.deserialize([])
  end

  test "points deserialise nil values correctly" do
    assert_nil Place::Point::Field.new.deserialize(nil)
  end

  test "points serialize nil correctly" do
    assert_nil Place::Point::Field.new.serialize(nil)
  end

end
