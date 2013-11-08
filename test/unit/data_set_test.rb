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

  context "activating a data_set" do
    setup do
      @service = FactoryGirl.create(:service)
    end

    should "set the active data_set on the service and return true" do
      ds = @service.data_sets.create!
      assert ds.activate

      @service.reload
      assert_equal ds.version, @service.active_data_set_version
    end

    should "do nothing and return false if the data_set hasn't completed processing" do
      previous_active_set = @service.active_data_set

      ds = @service.data_sets.create!(:csv_data => "something")
      refute ds.activate

      @service.reload
      assert_equal previous_active_set.version, @service.active_data_set_version
    end
  end

  context "archiving a data_set" do
    setup do
      @service = FactoryGirl.create(:service)
      FactoryGirl.create(
	:place,
	service_slug: @service.slug,
	data_set_version: 1
      )
    end

    should "archive its place information" do
      @service.data_sets.first.archive_places
      refute_empty PlaceArchive.all
    end

    should "remove its place information" do
      ds = @service.data_sets.first
      ds.archive_places
      assert_empty ds.places
    end

    should "flag it as archived" do
      ds = @service.data_sets.first
      ds.archive!
      ds.archive_places
      assert ds.archived?
    end

    should "handle an exception when archiving a place" do
      PlaceArchive.any_instance.stubs(:save!).raises(Exception)
      ds = @service.data_sets.first
      ds.archive_places
      assert_match /Failed/, ds.archiving_error
      assert ds.unarchived?
    end
  end

  context "creating a data_set with a data_file" do
    setup do
      Sidekiq::Testing.fake!
      @service = FactoryGirl.create(:service)
    end

    should "create a data_set, store the csv_data and queue a job to process it" do
      ds = @service.data_sets.create!(:data_file => File.open(fixture_file_path('good_csv.csv')))

      assert_equal File.read(fixture_file_path('good_csv.csv')), ds.csv_data

      job = Sidekiq::Delay::Worker.jobs.last
      instance_ary, method_name, args = YAML.load(job['args'].first)
      
      assert_equal @service, instance_ary.first.send('find', instance_ary.second)
      assert_equal :process_csv_data, method_name
      assert_equal ds.version, args.first
    end

    context "validating file size" do
      setup do
        @ds = @service.data_sets.build
      end

      should "be valid with a file up to 15M" do
        @ds.csv_data = "x" * (15.megabytes - 1)
        assert @ds.valid?
      end

      should "be invalid with a file over 15M" do
        @ds.csv_data = "x" * (15.megabytes + 1)
        refute @ds.valid?
        assert_equal 1, @ds.errors[:csv_data].size
      end

    end

    context "handling various file encodings" do
      setup do
        @ds = @service.data_sets.build
      end

      should "handle ASCII files" do
        @ds.data_file = File.open(fixture_file_path('encodings/ascii.csv'), :encoding => 'ascii-8bit')
        @ds.save!
        expected = File.read(fixture_file_path('encodings/ascii.csv'))
        assert_equal expected, @ds.csv_data
      end

      should "handle UTF-8 files" do
        @ds.data_file = File.open(fixture_file_path('encodings/utf-8.csv'), :encoding => 'ascii-8bit')
        @ds.save!
        expected = File.read(fixture_file_path('encodings/utf-8.csv'))
        assert_equal expected, @ds.csv_data
      end

      should "handle ISO-8859-1 files" do
        @ds.data_file = File.open(fixture_file_path('encodings/iso-8859-1.csv'), :encoding => 'ascii-8bit')
        @ds.save!
        expected = File.read(fixture_file_path('encodings/iso-8859-1.csv')).force_encoding('iso-8859-1').encode('utf-8')
        assert_equal expected, @ds.csv_data
      end

      should "handle Windows 1252 files" do
        @ds.data_file = File.open(fixture_file_path('encodings/windows-1252.csv'), :encoding => 'ascii-8bit')
        @ds.save!
        expected = File.read(fixture_file_path('encodings/windows-1252.csv')).force_encoding('windows-1252').encode('utf-8')
        assert_equal expected, @ds.csv_data
      end

      should "raise an error with an unknown file encoding" do
        assert_raise InvalidCharacterEncodingError do
          @ds.data_file = File.open(fixture_file_path('encodings/utf-16le.csv'), :encoding => 'ascii-8bit')
        end
      end
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

    should "store an error message, and clear the csv_data with an invalid csv" do
      ds = @service.data_sets.create!(:csv_data => File.read(fixture_file_path('bad_csv.csv')))
      ds.process_csv_data

      ds.reload
      assert_equal "Could not process CSV file. Please check the format.", ds.processing_error
      assert_nil ds.csv_data
    end

    context "processing state predicates" do
      should "be processing_complete with no csv_data and no processing_error" do
        ds = @service.data_sets.build(:csv_data => nil, :processing_error => nil)
        assert ds.processing_complete?
      end

      should "not be processing_complete with csv_data" do
        ds = @service.data_sets.build(:csv_data => "anything", :processing_error => nil)
        refute ds.processing_complete?
      end

      should "not be processing_complete with processing_error" do
        ds = @service.data_sets.build(:csv_data => nil, :processing_error => "something went wrong")
        refute ds.processing_complete?
      end
    end
  end
end
