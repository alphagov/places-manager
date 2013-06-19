require 'test_helper'

class PointTest < ActiveSupport::TestCase
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
end
