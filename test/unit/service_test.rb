require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  context "validations" do
    setup do
      @service = FactoryBot.build(:service)
    end

    should "have a valid factory" do
      assert @service.valid?
    end

    should "require a name" do
      @service.name = ""
      assert_not @service.valid?
      assert_equal 1, @service.errors[:name].count
    end

    context "on slug" do
      should "be required" do
        @service.slug = ""
        assert_not @service.valid?
        assert_equal 1, @service.errors[:slug].count
      end

      should "be unique" do
        FactoryBot.create(:service, slug: "a-service")
        @service.slug = "a-service"
        assert_not @service.valid?
        assert_equal 1, @service.errors[:slug].count
      end

      should "have database level uniqueness constraint" do
        FactoryBot.create(:service, slug: "a-service")
        @service.slug = "a-service"
        assert_raises Mongoid::Errors::InvalidPersistenceOption do
          @service.with(safe: true).save validate: false
        end
      end

      should "look like a slug" do
        [
          "a space",
          "full.stop",
          "this&that",
        ].each do |slug|
          @service.slug = slug
          assert_not @service.valid?
          assert_equal 1, @service.errors[:slug].count
        end

        %w[
          dashed-with-numbers-123
          under_score
        ].each do |slug|
          @service.slug = slug
          assert @service.valid?
        end
      end
    end

    should "require location_match_type to be one of the allowed values" do
      Service::LOCATION_MATCH_TYPES.each do |match_type|
        @service.location_match_type = match_type
        assert @service.valid?, "Expected service to be valid with location_match_type: '#{match_type}'"
      end

      [
        "",
        "fooey",
      ].each do |match_type|
        @service.location_match_type = match_type
        assert_not @service.valid?, "Expected service to be invalid with location_match_type: '#{match_type}'"
        assert_equal 1, @service.errors[:location_match_type].count
      end
    end

    should "require local_authority_hierarchy_match_type to be one of the allowed values" do
      Service::LOCAL_AUTHORITY_HIERARCHY_MATCH_TYPES.each do |match_type|
        @service.local_authority_hierarchy_match_type = match_type
        assert @service.valid?, "Expected service to be valid with local_authority_hierarchy_match_type: '#{match_type}'"
      end

      [
        "",
        "fooey",
      ].each do |match_type|
        @service.local_authority_hierarchy_match_type = match_type
        assert_not @service.valid?, "Expected service to be invalid with local_authority_hierarchy_match_type: '#{match_type}'"
        assert_equal 1, @service.errors[:local_authority_hierarchy_match_type].count
      end
    end
  end

  should "default location_match_type to 'nearest'" do
    assert_equal "nearest", Service.new.location_match_type
  end

  should "default local_authority_hierarchy_match_type to 'district'" do
    assert_equal "district", Service.new.local_authority_hierarchy_match_type
  end

  should "create an initial data_set when creating a service" do
    Service.create!(
      name: "Important Government Service",
      slug: "important-government-service",
    )

    s = Service.first
    assert_equal 1, s.data_sets.count
  end

  context "creating a service with a data_file" do
    should "create a data_set, store the csv_data and queue a job to process it" do
      Sidekiq::Testing.fake!

      attrs = FactoryBot.attributes_for(:service)
      attrs[:data_file] = File.open(fixture_file_path("good_csv.csv"))
      s = Service.create!(attrs)

      assert_equal 1, s.data_sets.count
      assert s.latest_data_set.csv_data
      assert_equal File.read(fixture_file_path("good_csv.csv")), s.latest_data_set.csv_data.data

      job = ProcessCsvDataWorker.jobs.last
      service_id_to_process, version_to_process = *job["args"]

      assert_equal s, Service.find(service_id_to_process)
      assert_equal s.latest_data_set.version, version_to_process
    end
  end

  context "current scope" do
    setup do
      @service = FactoryBot.create(:service)
    end

    should "return data_sets which have not been archived" do
      assert_not_empty @service.data_sets.current
    end

    should "return data_sets which are being archived" do
      @service.data_sets.first.set(state: "archiving")
      assert_not_empty @service.data_sets.current
    end

    should "not return archived data_sets" do
      @service.data_sets.first.set(state: "archived")
      assert_empty @service.data_sets.current
    end
  end

  context "archiving of places" do
    setup do
      ArchivePlacesWorker.jobs.clear
      Sidekiq::Testing.fake!
      @service = FactoryBot.create(:service, active_data_set_version: 3)
      @service.data_sets.create!
      @service.data_sets.create!
      FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: 1,
      )
    end

    should "not transition obsolete data_sets without places to archiving" do
      ds = @service.data_sets.first
      ds.places.delete_all
      @service.schedule_archive_places
      assert_not ds.archiving?
    end

    should "schedule the archiving of obsolete data_sets with places" do
      @service.schedule_archive_places
      job = ArchivePlacesWorker.jobs.last
      service_id_to_process = job["args"].first
      assert_equal @service, Service.find(service_id_to_process)
      assert_equal 1, ArchivePlacesWorker.jobs.count
      assert @service.data_sets.first.archiving?
    end

    should "not archive obsolete data_sets without places" do
      ds = @service.data_sets.first
      ds.places.delete_all
      @service.archive_places
      assert ds.unarchived?
    end
  end

  context "identifying obsolete data sets" do
    setup do
      @service = FactoryBot.create(:service)
      @service.data_sets.create!
      @service.data_sets.create!
    end

    should "not return any sets if the oldest data set is the active set" do
      assert_empty @service.obsolete_data_sets
    end

    should "not return any sets if the second oldest set is the active set" do
      @service.update!(active_data_set_version: 2)
      assert_empty @service.obsolete_data_sets
    end

    should "return sets up to but not including the set before the active set" do
      @service.update!(active_data_set_version: 3)
      assert_includes @service.obsolete_data_sets, @service.data_sets.first
      assert_equal 1, @service.obsolete_data_sets.count
    end
  end
end
