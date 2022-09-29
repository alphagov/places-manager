class DeleteHistoricRecordsWorker
  include Sidekiq::Worker

  def perform(service_id)
    service = Service.find(service_id)
    service.delete_historic_records
  end
end
