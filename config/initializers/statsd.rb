require "imminence/stats_collector"

ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Imminence::StatsCollector.timing(
    event.duration, event.payload[:controller].underscore, event.payload[:action]
  )
end
