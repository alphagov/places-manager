require "rails_helper"
require "places_manager/stats_collector"

RSpec.describe(PlacesManager::StatsCollector, type: :model) do
  it "prefixes admin requests with .admin" do
    result = PlacesManager::StatsCollector.prefix_controller("admin/foo")
    expect(result).to(eq("admin.foo"))
  end

  it "prefixes non admin requests with .api" do
    result = PlacesManager::StatsCollector.prefix_controller("foo")
    expect(result).to(eq("api.foo"))
  end

  it "sends the correct message to statsd" do
    statsd = double
    expect(statsd).to receive(:timing).with("response_time.api.foo.show", 3)
    allow(PlacesManager::StatsCollector).to receive(:statsd).and_return(statsd)
    PlacesManager::StatsCollector.timing(3, "foo", "show")
  end
end
