class ArchivePlacesWorker
  include Sidekiq::Worker

  def perform(service_id)
    Service.find(service_id).archive_places
  end
end
