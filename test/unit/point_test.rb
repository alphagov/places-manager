require "test_helper"

class PointTest < ActiveSupport::TestCase
  test "can create a Point" do
    point = Point.new(latitude: 56.2, longitude: -1.0)
    assert_equal 56.2, point.latitude
    assert_equal(-1.0, point.longitude)
  end

  test "require both coordinates for a point" do
    assert_raises ArgumentError do Point.new(latitude: 12.5) end
    assert_raises ArgumentError do Point.new(longitude: 12.5) end
  end

  test "points can be compared for equality" do
    point_a, point_b = [[56, 0.1], [-20, 95]].map { |lat, lng|
      Point.new(latitude: lat, longitude: lng)
    }
    # Not using refute_equals as we're not testing for a value
    refute point_a == point_b
    refute point_b == point_a
  end

  test "equality checks return false for non-points" do
    point = Point.new(latitude: 56.2, longitude: -1.0)
    refute point == { "longitude" => -1.0, "latitude" => 56.2 }
    refute point == 12
  end

  context "serialising for mongoid" do
    context "serialising" do
      should "serialise a Point instance to a hash" do
        p = Point.new(latitude: 56.2, longitude: -1.0)

        assert_equal({ "latitude" => 56.2, "longitude" => -1.0 }, p.mongoize)
        assert_equal({ "latitude" => 56.2, "longitude" => -1.0 }, Point.mongoize(p))
      end

      should "serialise the fields in the required order" do
        # Mongo requires the fields to be in the order longitude, latitude
        # in order for the geospatial indes to work.
        p = Point.new(latitude: 56.2, longitude: -1.0)

        # Note: hashes in ruby 1.9 keep order
        expected = { "longitude" => -1.0, "latitude" => 56.2 }
        assert_equal expected.to_a, p.mongoize.to_a
      end

      should "serialise a hash back to a hash" do
        assert_equal({ "latitude" => 56.2, "longitude" => -1.0 }, Point.mongoize(latitude: 56.2, longitude: -1.0))
      end

      should "serialise a hash with string keys back to a hash" do
        assert_equal({ "latitude" => 56.2, "longitude" => -1.0 }, Point.mongoize("latitude" => 56.2, "longitude" => -1.0))
      end

      should "serialise nil as nil" do
        assert_nil Point.mongoize(nil)
      end
    end

    context "deserialising" do
      should "deserialise a hash" do
        p = Point.demongoize("latitude" => 56.2, "longitude" => -1.0)

        assert p.is_a?(Point)
        assert_equal 56.2, p.lat
        assert_equal(-1.0, p.lng)
      end

      should "deserialise nil as nil" do
        assert_nil Point.demongoize(nil)
      end

      context "handling legacy array format" do
        should "deserialise an array" do
          p = Point.demongoize([56.2, -12.5])

          assert p.is_a?(Point)
          assert_equal 56.2, p.lat
          assert_equal(-12.5, p.lng)
        end

        should "deserialise empty array as nil" do
          assert_nil Point.demongoize([])
        end
      end
    end
  end
end
