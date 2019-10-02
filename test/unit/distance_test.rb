require "test_helper"

class DistanceTest < ActiveSupport::TestCase
  test "can create a distance" do
    d = Distance.new 500, :miles
    assert_equal 500, d.magnitude
    assert_equal :miles, d.unit
  end

  test "cannot create a distance with unknown units" do
    assert_raise RuntimeError do Distance.new(40, :rods) end
  end

  test "distances report themselves as strings" do
    assert_equal "500 miles", Distance.new(500, :miles).to_s
  end

  test "can convert distances between units" do
    d = Distance.new(500, :miles)
    assert_in_delta 7.228492642679549, d.in(:degrees), 1e-5
    assert_in_delta 0.12616099657094412, d.in(:radians), 1e-5
  end

  test "distances are not equal to numbers" do
    assert_not_equal 500, Distance.new(500, :miles)
  end
end
