require 'test_helper'

class DataSetTest < ActiveSupport::TestCase
  context "populating version" do
    setup do
      @service = FactoryGirl.create(:service)
    end

    should "set version to 1 for first set" do
      # Service creates an initial data_set by default
      assert_equal [1], Service.last.data_sets.map(&:version)
    end

    should "set versions on subsequent versions" do
      @service.data_sets.create
      @service.data_sets.create

      assert_equal [1,2,3], Service.first.data_sets.map(&:version)
    end

    should "cope with non-contiguous existing versions" do
      @service.data_sets.create(:version => 3)
      @service.data_sets.create

      assert_equal [1,3,4], Service.first.data_sets.map(&:version)
    end
  end
end
