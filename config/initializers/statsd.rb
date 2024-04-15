require "places_manager/stats_collector"

ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  PlacesManager::StatsCollector.timing(
    event.duration, event.payload[:controller].underscore, event.payload[:action]
  )
end
