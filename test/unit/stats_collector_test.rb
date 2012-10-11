require 'test_helper'
require "imminence/stats_collector"

class StatsCollectorTest < ActiveSupport::TestCase
  test "prefixes admin requests with .admin" do
    result = Imminence::StatsCollector.prefix_controller("admin/foo")
    assert_equal "admin.foo", result
  end

  test "prefixes non admin requests with .api" do
    result = Imminence::StatsCollector.prefix_controller("foo")
    assert_equal "api.foo", result
  end

  test "sends the correct message to statsd" do
    statsd = stub
    statsd.expects(:timing).with('response_time.api.foo.show', 3)
    Imminence::StatsCollector.stubs(:statsd).returns(statsd)
    Imminence::StatsCollector.timing(3, "foo", "show")
  end
end
