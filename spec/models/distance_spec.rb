require "rails_helper"

RSpec.describe(Distance, type: :model) do
  it "can create a distance" do
    d = Distance.new(500, :miles)
    expect(d.magnitude).to(eq(500))
    expect(d.unit).to(eq(:miles))
  end

  it "cannot create a distance with unknown units" do
    expect { Distance.new(40, :rods) }.to(raise_error(StandardError))
  end

  it "cannot create a distance from a non-number" do
    expect { Distance.new("hi", :miles) }.to(raise_error(StandardError))
  end

  it "distances report themselves as strings" do
    expect(Distance.new(500, :miles).to_s).to(eq("500 miles"))
  end

  it "can convert distances between units" do
    d = Distance.new(500, :miles)
    assert_in_delta(7.228492642679549, d.in(:degrees), 1.0e-05)
    assert_in_delta(0.12616099657094412, d.in(:radians), 1.0e-05)
  end

  it "distances are not equal to numbers" do
    expect(Distance.new(500, :miles)).to_not(eq(500))
  end
end
