require "test_helper"

class DeleteHistoricRecordsWorkerTest < ActiveSupport::TestCase
  context "running the worker" do
    setup do
      Sidekiq::Testing.inline!

      @service = FactoryBot.create(:service)
      @service.data_sets.delete_all
      FactoryBot.create_list(:archived_data_set, 6, service_id: @service.id)
      FactoryBot.create(:data_set, state: :unarchived, service_id: @service.id)
    end

    should "delete historic records" do
      assert_equal 7, @service.data_sets.count
      assert_equal 18, PlaceArchive.where(service_slug: @service.slug).count

      DeleteHistoricRecordsWorker.new.perform(@service.id)

      assert_equal 9, PlaceArchive.where(service_slug: @service.slug).count
      assert_equal [4, 5, 6, 7], @service.reload.data_sets.pluck(:version).sort
      @service.reload.data_sets.where(version: [4, 5, 6]).each do |data_set|
        assert_equal 3, PlaceArchive.where(service_slug: @service.slug,
                                           data_set_version: data_set.version).count
      end
    end
  end
end
