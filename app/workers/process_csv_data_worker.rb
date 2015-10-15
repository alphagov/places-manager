class ProcessCsvDataWorker
  include Sidekiq::Worker

  def perform(service_id, data_set_version)
    Service.find(service_id).process_csv_data(data_set_version)
  end
end
