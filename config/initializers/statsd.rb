class StatsD
  def self.statsd
    @statsd ||= Statsd.new("localhost").tap do |c|
      c.namespace = ENV['GOVUK_STATSD_PREFIX'].to_s
    end
  end

  def self.timing(time)
    statsd.timing("response_time", time)
  end
end

ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  StatsD.timing(event.duration)
end