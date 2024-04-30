require "rails_helper"

RSpec.describe(DeleteHistoricRecordsWorker, type: :model) do
  before do
    Sidekiq::Testing.inline!
    @service = FactoryBot.create(:service)
    @service.data_sets.delete_all
    FactoryBot.create_list(:archived_data_set, 6, service_id: @service.id)
    FactoryBot.create(:data_set, state: :unarchived, service_id: @service.id)
  end

  it "deletes historic records" do
    expect(@service.data_sets.count).to(eq(7))
    expect(PlaceArchive.where(service_slug: @service.slug).count).to(eq(18))
    DeleteHistoricRecordsWorker.new.perform(@service.id)
    expect(PlaceArchive.where(service_slug: @service.slug).count).to(eq(9))
    expect(@service.reload.data_sets.pluck(:version).sort).to(eq([4, 5, 6, 7]))
    @service.reload.data_sets.where(version: [4, 5, 6]).find_each do |data_set|
      expect(PlaceArchive.where(service_slug: @service.slug, data_set_version: data_set.version).count).to(eq(3))
    end
  end
end
