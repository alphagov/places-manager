require "rails_helper"

RSpec.describe(Service, type: :model) do
  context "validations" do
    before { @service = FactoryBot.build(:service) }

    it "has a valid factory" do
      expect(@service.valid?).to(eq(true))
    end

    it "requires a name" do
      @service.name = ""
      expect(@service.valid?).to be false
      expect(@service.errors[:name].count).to(eq(1))
    end

    context "on slug" do
      it "is required" do
        @service.slug = ""
        expect(@service.valid?).to be false
        expect(@service.errors[:slug].count).to(eq(1))
      end

      it "is unique" do
        FactoryBot.create(:service, slug: "a-service")
        @service.slug = "a-service"
        expect(@service.valid?).to be false
        expect(@service.errors[:slug].count).to(eq(1))
      end

      it "has database level uniqueness constraint" do
        FactoryBot.create(:service, slug: "a-service")
        @service.slug = "a-service"
        expect { @service.save(validate: false) }.to(raise_error(ActiveRecord::RecordNotUnique))
      end

      it "looks like a slug" do
        ["a space", "full.stop", "this&that"].each do |slug|
          @service.slug = slug
          expect(@service.valid?).to be false
          expect(@service.errors[:slug].count).to(eq(1))
        end

        %w[dashed-with-numbers-123 under_score].each do |slug|
          @service.slug = slug
          expect(@service.valid?).to(eq(true))
        end
      end
    end

    it "requires location_match_type to be one of the allowed values" do
      Service::LOCATION_MATCH_TYPES.each do |match_type|
        @service.location_match_type = match_type
        expect(@service.valid?).to(eq(true))
      end

      ["", "fooey"].each do |match_type|
        @service.location_match_type = match_type
        expect(@service.valid?).to be false
        expect(@service.errors[:location_match_type].count).to(eq(1))
      end
    end

    it "requires local_authority_hierarchy_match_type to be one of the allowed values" do
      Service::LOCAL_AUTHORITY_HIERARCHY_MATCH_TYPES.each do |match_type|
        @service.local_authority_hierarchy_match_type = match_type
        expect(@service.valid?).to(eq(true))
      end

      ["", "fooey"].each do |match_type|
        @service.local_authority_hierarchy_match_type = match_type
        expect(@service.valid?).to be false
        expect(@service.errors[:local_authority_hierarchy_match_type].count).to(eq(1))
      end
    end
  end

  it "defaults location_match_type to 'nearest'" do
    expect(Service.new.location_match_type).to(eq("nearest"))
  end

  it "defaults local_authority_hierarchy_match_type to 'district'" do
    expect(Service.new.local_authority_hierarchy_match_type).to(eq("district"))
  end

  it "creates an initial data_set when creating a service" do
    Service.create!(name: "Important Government Service", slug: "important-government-service")
    s = Service.first
    expect(s.data_sets.count).to(eq(1))
  end

  context "creating a service with a data_file" do
    it "creates a data_set, store the csv_data and queue a job to process it" do
      Sidekiq::Testing.fake!
      attrs = FactoryBot.attributes_for(:service)
      attrs[:data_file] = File.open(fixture_file_path("good_csv.csv"))
      s = Service.create!(attrs)
      expect(s.data_sets.count).to(eq(1))
      expect(s.latest_data_set.csv_data).to(be_truthy)
      expect(s.latest_data_set.csv_data.data).to(eq(File.read(fixture_file_path("good_csv.csv"))))
      job = ProcessCsvDataWorker.jobs.last
      service_id_to_process, version_to_process = *job["args"]
      expect(Service.find(service_id_to_process)).to(eq(s))
      expect(version_to_process).to(eq(s.latest_data_set.version))
    end
  end

  context "current scope" do
    before { @service = FactoryBot.create(:service) }

    it "returns data_sets which have not been archived" do
      expect(@service.data_sets.current).not_to be_empty
    end

    it "returns data_sets which are being archived" do
      @service.data_sets.first.update!(state: "archiving")
      expect(@service.data_sets.current).not_to be_empty
    end

    it "does not return archived data_sets" do
      @service.data_sets.first.update!(state: "archived")
      expect(@service.data_sets.current).to(be_empty)
    end
  end

  context "archiving of places" do
    before do
      ArchivePlacesWorker.jobs.clear
      Sidekiq::Testing.fake!
      @service = FactoryBot.create(:service, active_data_set_version: 3)
      @service.data_sets.create!
      @service.data_sets.create!
      FactoryBot.create(:place, service_slug: @service.slug, data_set_version: 1)
    end

    it "does not transition obsolete data_sets without places to archiving" do
      ds = @service.data_sets.first
      ds.places.delete_all
      @service.schedule_archive_places
      expect(ds.archiving?).to be false
    end

    it "schedules the archiving of obsolete data_sets with places" do
      @service.schedule_archive_places
      job = ArchivePlacesWorker.jobs.last
      service_id_to_process = job["args"].first
      expect(Service.find(service_id_to_process)).to(eq(@service))
      expect(ArchivePlacesWorker.jobs.count).to(eq(1))
      expect(@service.data_sets.first.archiving?).to(eq(true))
    end

    it "deletes archive obsolete data_sets without places" do
      ds = @service.data_sets.first
      ds.places.delete_all
      @service.archive_places
      expect(ds.persisted?).to be false
    end

    it "doesn't action already archived data_sets" do
      archived_ds = FactoryBot.create(:archived_data_set, service: @service)
      @service.archive_places
      expect(archived_ds.persisted?).to(eq(true))
    end
  end

  context "scheduling deletion of historic records" do
    it "schedules deletion" do
      service = FactoryBot.create(:service)
      expect(DeleteHistoricRecordsWorker).to receive(:perform_async).with(service.id)
      service.schedule_delete_historic_records
    end
  end

  context "deleting historic records" do
    before do
      @service = FactoryBot.create(:service)
      @service.data_sets.delete_all
    end

    it "deletes oldest records if there are more than 3 data sets archived" do
      FactoryBot.create_list(:archived_data_set, 4, service_id: @service.id)
      FactoryBot.create(:data_set, state: :unarchived, service_id: @service.id)
      data_set_ids = @service.data_sets.order(:version).pluck(:id)
      undeleted_data_sets = data_set_ids.drop(1)
      @service.delete_historic_records
      expect(@service.data_sets.order(:version).map(&:id)).to(eq(undeleted_data_sets))
    end

    it "doesn't delete oldest records if there are less than 4 data sets archived" do
      FactoryBot.create_list(:archived_data_set, 3, service: @service)
      @unarchived_data_set = FactoryBot.create(:data_set, state: :unarchived, service: @service)
      @service.data_sets.each do |data_set|
        data_set.expects(:delete_historic_records).never
      end
    end
  end

  context "identifying obsolete data sets" do
    before do
      @service = FactoryBot.create(:service)
      @service.data_sets.create!
      @service.data_sets.create!
    end

    it "does not return any sets if the oldest data set is the active set" do
      expect(@service.obsolete_data_sets).to(be_empty)
    end

    it "does not return any sets if the second oldest set is the active set" do
      @service.update!(active_data_set_version: 2)
      expect(@service.obsolete_data_sets).to(be_empty)
    end

    it "returns sets up to but not including the set before the active set" do
      @service.update!(active_data_set_version: 3)
      assert_includes(@service.obsolete_data_sets, @service.data_sets.first)
      expect(@service.obsolete_data_sets.count).to(eq(1))
    end
  end
end
