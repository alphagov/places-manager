class FixGeoencodeErrorsWorker
  include Sidekiq::Worker

  def perform(service_id, data_set_version)
    Service.find(service_id).data_sets.find_by(version: data_set_version).places.with_geocoding_errors.each(&:geocode!)
  end
end
