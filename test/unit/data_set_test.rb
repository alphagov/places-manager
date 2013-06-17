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

  context "creating a data_set with a data_file" do
    setup do
      @service = FactoryGirl.create(:service)
    end

    should "create a data_set, store the csv_data and queue a job to process it" do
      ds = @service.data_sets.create!(:data_file => File.open(fixture_file_path('good_csv.csv')))

      assert_equal File.read(fixture_file_path('good_csv.csv')), ds.csv_data

      job = Delayed::Job.last
      handler = YAML.load(job.handler)
      assert_equal @service, handler.object
      assert_equal :process_csv_data, handler.method_name
      assert_equal ds.version, handler.args.first
    end
  end

  context "processing csv data" do
    setup do
      @service = FactoryGirl.create(:service)
    end

    should "add all places from the csv_data" do
      ds = @service.data_sets.create!(:csv_data => File.read(fixture_file_path('good_csv.csv')))
      ds.process_csv_data

      assert_equal 1, ds.places.count
      assert_equal "1 Stop Instruction", ds.places.first.name
    end

    should "clear the stored csv_data" do
      ds = @service.data_sets.create!(:csv_data => File.read(fixture_file_path('good_csv.csv')))
      ds.process_csv_data

      ds.reload
      assert_nil ds.csv_data
    end
  end
end
