class DuplicateDataSetWorker
  include Sidekiq::Worker

  def perform(service_id, data_set_id)
    service = Service.find(service_id)
    service.data_sets.where("id" => data_set_id).first.duplicate
  end
end
