class Imminence::StatsCollector
  def self.statsd
    @statsd ||= Statsd.new("localhost").tap do |c|
      c.namespace = ENV['GOVUK_STATSD_PREFIX'].to_s
    end
  end

  def self.timing(time, controller, action)
    statsd.timing("response_time.#{controller}.#{action}", time)
  end
end

ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Imminence::StatsCollector.timing(
    event.duration, event.payload[:controller].underscore, event.payload[:action]
  )
end