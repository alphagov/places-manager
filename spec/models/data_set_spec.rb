require "rails_helper"
require "gds_api/test_helpers/local_links_manager"
require "gds_api/test_helpers/locations_api"

RSpec.describe(DataSet, type: :model) do
  include GdsApi::TestHelpers::LocalLinksManager
  include GdsApi::TestHelpers::LocationsApi

  context "populating version" do
    before { @service = FactoryBot.create(:service) }

    it "sets version to 1 for first set" do
      expect(Service.last.data_sets.map(&:version)).to(eq([1]))
    end

    it "sets versions on subsequent versions" do
      @service.data_sets.create!
      @service.data_sets.create!
      expect(Service.last.data_sets.map(&:version)).to(eq([1, 2, 3]))
    end

    it "copes with non-contiguous existing versions" do
      @service.data_sets.create!(version: 3)
      @service.data_sets.create!
      expect(Service.last.data_sets.map(&:version)).to(eq([1, 3, 4]))
    end
  end

  context "activating a data_set" do
    before { @service = FactoryBot.create(:service) }

    it "sets the active data_set on the service and return true" do
      ds = @service.data_sets.create!
      expect(ds.activate).to(be_truthy)
      @service.reload
      expect(@service.active_data_set_version).to(eq(ds.version))
    end

    it "does nothing and return false if the data_set hasn't completed processing" do
      previous_active_set = @service.active_data_set
      create_uploaded_file("anything") do |file|
        ds = @service.data_sets.create!(data_file: file)
        expect(ds.activate).to be false
        @service.reload
        expect(@service.active_data_set_version).to(eq(previous_active_set.version))
      end
    end
  end

  context "archiving a data_set" do
    before do
      @service = FactoryBot.create(:service)
      FactoryBot.create_list(:place, 5, service_slug: @service.slug)
    end

    it "archives its place information" do
      expect(PlaceArchive.all).to(be_empty)
      @service.data_sets.first.archive_places
      expect(PlaceArchive.all.count).to(eq(5))
    end

    it "does not copy ids when archiving, so that we don't get clashes" do
      ds = @service.data_sets.first
      FactoryBot.create(:place_archive, id: ds.places.first.id)
      ActiveRecord::Base.connection.reset_pk_sequence!("place_archives")
      ds.archive!
      ds.archive_places
      expect(ds.archived?).to(eq(true))
      expect(ds.archiving_error).to(be_nil)
    end

    it "removes its place information" do
      ds = @service.data_sets.first
      ds.archive_places
      expect(ds.places).to(be_empty)
    end

    it "flags it as archived" do
      ds = @service.data_sets.first
      ds.archive!
      ds.archive_places
      expect(ds.archived?).to(eq(true))
    end

    it "handles errors when archiving a place" do
      allow(PlaceArchive).to receive(:create!).and_raise("A problem occurred")
      ds = @service.data_sets.first
      ds.archive_places
      expect(ds.archiving_error).to(match(/Failed/))
      expect(ds.archiving_error).to(match(/'A problem occurred'/))
      expect(ds.unarchived?).to(eq(true))
    end
  end

  context "deleting records" do
    before do
      @service = FactoryBot.create(:service)
      @service.data_sets.delete_all
      @data_set_version = FactoryBot.create(:archived_data_set, service_id: @service.id).version
      @service.reload
    end

    it "deletes data sets and associated place archives" do
      place_archives = PlaceArchive.where(service_slug: @service.slug, data_set_version: @data_set_version)
      expect(place_archives.count).to(eq(3))
      expect(@service.data_sets.count).to(eq(1))
      @service.data_sets.last.delete_records
      expect(place_archives.count).to(eq(0))
      expect(@service.data_sets.count).to(eq(0))
    end
  end

  context "creating a data_set with a data_file" do
    before do
      Sidekiq::Testing.fake!
      @service = FactoryBot.create(:service)
    end

    it "creates a data_set, store the csv_data and queue a job to process it" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
      expect(ds.csv_data.data).to(eq(File.read(fixture_file_path("good_csv.csv"))))
      job = ProcessCsvDataWorker.jobs.last
      service_id_to_process, version_to_process = *job["args"]
      expect(Service.find(service_id_to_process)).to(eq(@service))
      expect(version_to_process).to(eq(ds.version))
    end

    context "validating file size" do
      before { @ds = @service.data_sets.build }

      it "is valid with a file up to 15M" do
        create_uploaded_file(("x" * (15.megabytes - 1))) do |file|
          @ds.data_file = file
          expect(@ds.valid?).to(eq(true))
        end
      end

      it "is invalid with a file over 15M" do
        create_uploaded_file(("x" * (15.megabytes + 1))) do |file|
          @ds.data_file = file
          expect(@ds.valid?).to be false
          expect(@ds.errors[:data_file].size).to(eq(1))
        end
      end
    end

    context "handling various file encodings" do
      before { @ds = @service.data_sets.build }

      it "handles ASCII files" do
        @ds.data_file = File.open(fixture_file_path("encodings/ascii.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/ascii.csv"))
        expect(@ds.csv_data.data).to(eq(expected))
      end

      it "handles UTF-8 files" do
        @ds.data_file = File.open(fixture_file_path("encodings/utf-8.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/utf-8.csv"))
        expect(@ds.csv_data.data).to(eq(expected))
      end

      it "handles ISO-8859-1 files" do
        @ds.data_file = File.open(fixture_file_path("encodings/iso-8859-1.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/iso-8859-1.csv")).force_encoding("iso-8859-1").encode("utf-8")
        expect(@ds.csv_data.data).to(eq(expected))
      end

      it "handles Windows 1252 files" do
        @ds.data_file = File.open(fixture_file_path("encodings/windows-1252.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/windows-1252.csv")).force_encoding("windows-1252").encode("utf-8")
        expect(@ds.csv_data.data).to(eq(expected))
      end

      it "raises an error with an unknown file encoding" do
        expect {
          @ds.data_file = File.open(fixture_file_path("encodings/utf-16le.csv"), encoding: "ascii-8bit")
        }.to(raise_error(InvalidCharacterEncodingError))
      end
    end
  end

  context "processing csv data" do
    before do
      stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
      @service = FactoryBot.create(:service)
    end

    it "adds all places from the csv_data" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
      ds.process_csv_data
      expect(ds.places.count).to(eq(1))
      expect(ds.places.first.name).to(eq("1 Stop Instruction"))
    end

    it "cleard the stored csv_data" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
      ds.process_csv_data
      ds.reload
      expect(ds.csv_data).to(be_nil)
    end

    it "stores an error message, and clear the csv_data with an invalid csv" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("bad_csv.csv")))
      ds.process_csv_data
      ds.reload
      expect(ds.processing_error).to(eq("Could not process CSV file. Please check the format."))
      expect(ds.csv_data).to(be_nil)
    end

    context "processing state predicates" do
      it "is processing_complete with no csv_data and no processing_error" do
        ds = @service.data_sets.build(data_file: nil, processing_error: nil)
        expect(ds.processing_complete?).to(eq(true))
      end

      it "is not processing_complete with csv_data" do
        create_uploaded_file("anything") do |file|
          ds = @service.data_sets.build(data_file: file, processing_error: nil)
          expect(ds.processing_complete?).to be false
        end
      end

      it "is not processing_complete with processing_error" do
        ds = @service.data_sets.build(data_file: nil, processing_error: "something went wrong")
        expect(ds.processing_complete?).to be false
      end
    end
  end

  context "places near a point" do
    before do
      @service = FactoryBot.create(:service)
      @buckingham_palace = Place.create!(service_slug: @service.slug, data_set_version: @service.latest_data_set.version, postcode: "SW1A 1AA", source_address: "Buckingham Palace, Westminster", override_lat: "51.501009611553926", override_lng: "-0.141587067110009")
      @aviation_house = Place.create!(service_slug: @service.slug, data_set_version: @service.latest_data_set.version, postcode: "WC2B 6SE", source_address: "Aviation House", override_lat: "51.516960431", override_lng: "-0.120586400134")
      @scottish_parliament = Place.create!(service_slug: @service.slug, data_set_version: @service.latest_data_set.version, postcode: "EH99 1SP", source_address: "Scottish Parliament", override_lat: "55.95439", override_lng: "-3.174706")
    end

    it "finds places near a point in distance order" do
      places = @service.latest_data_set.places_near(@buckingham_palace.location)
      expected_places = [@buckingham_palace, @aviation_house, @scottish_parliament]
      expect(places.to_a).to(eq(expected_places))
      distances_in_miles = [0, 1.42, 332.08]
      places.to_a.zip(distances_in_miles).each do |place, expected_distance|
        assert_in_epsilon(expected_distance, place.dis.in(:miles), 0.01)
      end
    end

    it "constrains returned points by distance" do
      centre = @buckingham_palace.location
      places = @service.latest_data_set.places_near(centre, Distance.miles(1.4))
      expect(places.unscope(:select).count).to(eq(1))
      places = @service.latest_data_set.places_near(centre, Distance.miles(1.45))
      expect(places.unscope(:select).count).to(eq(2))
    end

    it "works when constraining points by a large distance" do
      centre = @buckingham_palace.location
      places = @service.latest_data_set.places_near(centre, Distance.miles(330))
      expect(places.unscope(:select).count).to(eq(2))
      places = @service.latest_data_set.places_near(centre, Distance.miles(333))
      expect(places.unscope(:select).count).to(eq(3))
    end

    it "limits number of results" do
      places = @service.latest_data_set.places_near(@buckingham_palace.location, nil, 2)
      expect(places.unscope(:select).count).to(eq(2))
      expect(places.to_a).to(eq([@buckingham_palace, @aviation_house]))
    end

    it "limits on both distance and number of results" do
      centre = @buckingham_palace.location
      places = @service.latest_data_set.places_near(centre, Distance.miles(1.4), 2)
      expect(places.unscope(:select).count).to(eq(1))
      places = @service.latest_data_set.places_near(centre, Distance.miles(1.45), 2)
      expect(places.unscope(:select).count).to(eq(2))
      places = @service.latest_data_set.places_near(centre, Distance.miles(400), 2)
      expect(places.unscope(:select).count).to(eq(2))
    end

    it "constrains results to places belonging to the relevant data_set" do
      ds = @service.latest_data_set
      ds2 = @service.data_sets.create!
      service2 = FactoryBot.create(:service)
      FactoryBot.create(:place, service_slug: @service.slug, data_set_version: ds2.version)
      FactoryBot.create(:place, service_slug: service2.slug, data_set_version: service2.latest_data_set.version)
      expect(ds.places_near(@buckingham_palace.location).unscope(:select).count).to(eq(3))
      expect(ds.places_near(@buckingham_palace.location, Distance.miles(1.45)).unscope(:select).count).to(eq(2))
      expect(ds.places_near(@buckingham_palace.location, nil, 2).unscope(:select).count).to(eq(2))
      expect(ds.places_near(@buckingham_palace.location, Distance.miles(1.4), 2).unscope(:select).count).to(eq(1))
      expect(ds.places_near(@buckingham_palace.location, Distance.miles(400), 2).unscope(:select).count).to(eq(2))
    end
  end

  context "places_for_postcode" do
    context "for a 'nearest' service" do
      before do
        @service = FactoryBot.create(:service)
        @data_set = @service.latest_data_set
        @buckingham_palace = Place.create!(service_slug: @service.slug, data_set_version: @data_set.version, postcode: "SW1A 1AA", source_address: "Buckingham Palace, Westminster", override_lat: "51.501009611553926", override_lng: "-0.141587067110009")
        @aviation_house = Place.create!(service_slug: @service.slug, data_set_version: @data_set.version, postcode: "WC2B 6SE", source_address: "Aviation House", override_lat: "51.516960431", override_lng: "-0.120586400134")
        @scottish_parliament = Place.create!(service_slug: @service.slug, data_set_version: @data_set.version, postcode: "EH99 1SP", source_address: "Scottish Parliament", override_lat: "55.95439", override_lng: "-3.174706")
      end

      it "returns places near the postcode's location" do
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])
        expected_location = RGeo::Geographic.spherical_factory.point(-0.12058693935709164, 51.51695975170424)
        expect(@data_set).to receive(:places_near).with(expected_location, nil, nil).and_return(:some_places)
        expect(@data_set.places_for_postcode("WC2B 6NH")).to(eq(:some_places))
      end

      it "passes distance and limit params through to places_near" do
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])
        expect(@data_set).to receive(:places_near).with(anything, 14, 5).and_return(:some_places)
        expect(@data_set.places_for_postcode("WC2B 6NH", 14, 5)).to(eq(:some_places))
      end
    end

    context "for a 'nearest' service with two items in the same place" do
      before do
        @service = FactoryBot.create(:service)
        @data_set = @service.latest_data_set
        @buckingham_palace = Place.create!(service_slug: @service.slug, data_set_version: @data_set.version, postcode: "SW1A 1AA", source_address: "Buckingham Palace, Westminster", override_lat: "51.501009611553926", override_lng: "-0.141587067110009", name: "Buckingham Palace")
        @buckingham_palace2 = Place.create!(service_slug: @service.slug, data_set_version: @data_set.version, postcode: "SW1A 1AA", source_address: "Buckingham Palace, Westminster", override_lat: "51.501009611553926", override_lng: "-0.141587067110009", name: "Buckingham Palace 2")
      end

      it "returns the places in original order when the SQL seed is set to 0.5" do
        ActiveRecord::Base.connection.execute("SELECT SETSEED(0.5);")
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])
        place_names = @data_set.places_for_postcode("WC2B 6NH").map(&:name)
        expect(place_names).to(eq(["Buckingham Palace", "Buckingham Palace 2"]))
      end

      it "returns the places in reverse order when the SQL seed is set to 0.1" do
        ActiveRecord::Base.connection.execute("SELECT SETSEED(0.1);")
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])
        place_names = @data_set.places_for_postcode("WC2B 6NH").map(&:name)
        expect(place_names).to(eq(["Buckingham Palace 2", "Buckingham Palace"]))
      end
    end

    context "for a 'local_authority' service" do
      before do
        @service = FactoryBot.create(:service, location_match_type: "local_authority")
        @data_set = @service.latest_data_set
        @place1 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345678", postcode: "EX39 1QS", latitude: 51.05318361810428, longitude: -4.191071523498792, name: "John's Of Appledore")
        @place2 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345678", postcode: "EX39 1PP", latitude: 51.053834, longitude: -4.191422, name: "Susie's Tea Rooms")
        @place3 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345679", postcode: "WC2B 6NH", latitude: 51.51695975170424, longitude: -0.12058693935709164, name: "Aviation House")
        @place4 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345679", postcode: "WC1B 5HA", latitude: 51.51837458322272, longitude: -0.12133586354538765, name: "FreeState Coffee")
      end

      it "returns places in the same district/unitary authority as the postcode, matching by GSS" do
        stub_locations_api_has_location("EX39 1LH", [{ "latitude" => 51.0413792674, "longitude" => -4.23640704632, "local_custodian_code" => 1234 }])
        stub_local_links_manager_has_a_local_authority("county1", country_name: "England", gss: "E12345678", local_custodian_code: 1234)
        place_names = @data_set.places_for_postcode("EX39 1LH").map(&:name)
        expect(place_names).to(eq(["John's Of Appledore", "Susie's Tea Rooms"]))
      end

      it "returns multiple places in order of nearness if there are more than one in the district" do
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164, "local_custodian_code" => 1234 }])
        stub_local_links_manager_has_a_local_authority("county1", country_name: "England", gss: "E12345679", local_custodian_code: 1234)
        place_names = @data_set.places_for_postcode("WC2B 6NH").map(&:name)
        expect(place_names).to(eq(["Aviation House", "FreeState Coffee"]))
      end

      it "returns empty array if no GSS can be found for the postcode" do
        stub_locations_api_has_location("BT1 5GS", [{ "latitude" => 21.54, "longitude" => -5.93 }])
        expect(@data_set.places_for_postcode("BT1 5GS").to_a).to(eq([]))
      end
    end

    context "duplicating a data set" do
      before do
        allow_any_instance_of(DataSet).to receive(:duplicated).and_return(nil)
        service = FactoryBot.create(:service)
        data_set = service.latest_data_set
        @dupe = data_set.duplicate
      end

      it "marks the state of the duplicate data set as 'duplicating'" do
        expect(@dupe.state).to(eq("duplicating"))
      end
    end

    context "duplicated data set" do
      before do
        service = FactoryBot.create(:service)
        data_set = service.latest_data_set
        @dupe = data_set.duplicate
      end

      it "transitions from 'duplicating' to 'unarchived' once finished" do
        expect(@dupe.previous_changes["state"]).to(eq(%w[duplicating unarchived]))
      end
    end
  end

  def create_uploaded_file(contents)
    Tempfile.create do |temp_file|
      (temp_file << contents)
      temp_file.rewind
      file = ActionDispatch::Http::UploadedFile.new(filename: "new.csv", type: "text/csv", tempfile: temp_file)
      yield(file)
    end
  end
end
