require "test_helper"
require "gds_api/test_helpers/local_links_manager"
require "gds_api/test_helpers/locations_api"

class DataSetTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LocalLinksManager
  include GdsApi::TestHelpers::LocationsApi

  context "populating version" do
    setup do
      @service = FactoryBot.create(:service)
    end

    should "set version to 1 for first set" do
      # Service creates an initial data_set by default
      assert_equal [1], Service.last.data_sets.map(&:version)
    end

    should "set versions on subsequent versions" do
      @service.data_sets.create!
      @service.data_sets.create!

      assert_equal [1, 2, 3], Service.last.data_sets.map(&:version)
    end

    should "cope with non-contiguous existing versions" do
      @service.data_sets.create!(version: 3)
      @service.data_sets.create!

      assert_equal [1, 3, 4], Service.last.data_sets.map(&:version)
    end
  end

  context "activating a data_set" do
    setup do
      @service = FactoryBot.create(:service)
    end

    should "set the active data_set on the service and return true" do
      ds = @service.data_sets.create!
      assert ds.activate

      @service.reload
      assert_equal ds.version, @service.active_data_set_version
    end

    should "do nothing and return false if the data_set hasn't completed processing" do
      previous_active_set = @service.active_data_set

      create_uploaded_file("anything") do |file|
        ds = @service.data_sets.create!(data_file: file)
        assert_not ds.activate

        @service.reload
        assert_equal previous_active_set.version, @service.active_data_set_version
      end
    end
  end

  context "archiving a data_set" do
    setup do
      @service = FactoryBot.create(:service)
      FactoryBot.create_list(:place, 5, service_slug: @service.slug)
    end

    should "archive its place information" do
      assert_empty PlaceArchive.all
      @service.data_sets.first.archive_places
      assert_equal 5, PlaceArchive.all.count
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

    should "handles errors when archiving a place" do
      PlaceArchive.stubs(:create!).raises("A problem occurred")
      ds = @service.data_sets.first
      ds.archive_places
      assert_match(/Failed/, ds.archiving_error)
      assert_match(/'A problem occurred'/, ds.archiving_error)
      assert ds.unarchived?
    end
  end

  context "deleting records" do
    setup do
      @service = FactoryBot.create(:service)
      @service.data_sets.delete_all
      @data_set_version = FactoryBot.create(:archived_data_set, service_id: @service.id).version
      @service.reload
    end

    should "delete data sets and associated place archives" do
      place_archives = PlaceArchive.where(
        service_slug: @service.slug, data_set_version: @data_set_version,
      )

      assert_equal 3, place_archives.count
      assert_equal 1, @service.data_sets.count

      @service.data_sets.last.delete_records

      assert_equal 0, place_archives.count
      assert_equal 0, @service.data_sets.count
    end
  end

  context "creating a data_set with a data_file" do
    setup do
      Sidekiq::Testing.fake!
      @service = FactoryBot.create(:service)
    end

    should "create a data_set, store the csv_data and queue a job to process it" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))

      assert_equal File.read(fixture_file_path("good_csv.csv")), ds.csv_data.data

      job = ProcessCsvDataWorker.jobs.last
      service_id_to_process, version_to_process = *job["args"]

      assert_equal @service, Service.find(service_id_to_process)
      assert_equal ds.version, version_to_process
    end

    context "validating file size" do
      setup do
        @ds = @service.data_sets.build
      end

      should "be valid with a file up to 15M" do
        create_uploaded_file("x" * (15.megabytes - 1)) do |file|
          @ds.data_file = file
          assert @ds.valid?
        end
      end

      should "be invalid with a file over 15M" do
        create_uploaded_file("x" * (15.megabytes + 1)) do |file|
          @ds.data_file = file
          assert_not @ds.valid?
          assert_equal 1, @ds.errors[:data_file].size
        end
      end
    end

    context "handling various file encodings" do
      setup do
        @ds = @service.data_sets.build
      end

      should "handle ASCII files" do
        @ds.data_file = File.open(fixture_file_path("encodings/ascii.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/ascii.csv"))
        assert_equal expected, @ds.csv_data.data
      end

      should "handle UTF-8 files" do
        @ds.data_file = File.open(fixture_file_path("encodings/utf-8.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/utf-8.csv"))
        assert_equal expected, @ds.csv_data.data
      end

      should "handle ISO-8859-1 files" do
        @ds.data_file = File.open(fixture_file_path("encodings/iso-8859-1.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/iso-8859-1.csv")).force_encoding("iso-8859-1").encode("utf-8")
        assert_equal expected, @ds.csv_data.data
      end

      should "handle Windows 1252 files" do
        @ds.data_file = File.open(fixture_file_path("encodings/windows-1252.csv"), encoding: "ascii-8bit")
        @ds.save!
        expected = File.read(fixture_file_path("encodings/windows-1252.csv")).force_encoding("windows-1252").encode("utf-8")
        assert_equal expected, @ds.csv_data.data
      end

      should "raise an error with an unknown file encoding" do
        assert_raise InvalidCharacterEncodingError do
          @ds.data_file = File.open(fixture_file_path("encodings/utf-16le.csv"), encoding: "ascii-8bit")
        end
      end
    end
  end

  context "processing csv data" do
    setup do
      # NOTE: this is the postcode in good_csv.csv
      stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
      @service = FactoryBot.create(:service)
    end

    should "add all places from the csv_data" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
      ds.process_csv_data

      assert_equal 1, ds.places.count
      assert_equal "1 Stop Instruction", ds.places.first.name
    end

    should "clear the stored csv_data" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
      ds.process_csv_data

      ds.reload
      assert_nil ds.csv_data
    end

    should "store an error message, and clear the csv_data with an invalid csv" do
      ds = @service.data_sets.create!(data_file: File.open(fixture_file_path("bad_csv.csv")))
      ds.process_csv_data

      ds.reload
      assert_equal "Could not process CSV file. Please check the format.", ds.processing_error
      assert_nil ds.csv_data
    end

    context "processing state predicates" do
      should "be processing_complete with no csv_data and no processing_error" do
        ds = @service.data_sets.build(data_file: nil, processing_error: nil)
        assert ds.processing_complete?
      end

      should "not be processing_complete with csv_data" do
        create_uploaded_file("anything") do |file|
          ds = @service.data_sets.build(data_file: file, processing_error: nil)
          assert_not ds.processing_complete?
        end
      end

      should "not be processing_complete with processing_error" do
        ds = @service.data_sets.build(data_file: nil, processing_error: "something went wrong")
        assert_not ds.processing_complete?
      end
    end
  end

  context "places near a point" do
    setup do
      @service = FactoryBot.create(:service)
      @buckingham_palace = Place.create!(
        service_slug: @service.slug,
        data_set_version: @service.latest_data_set.version,
        postcode: "SW1A 1AA",
        source_address: "Buckingham Palace, Westminster",
        override_lat: "51.501009611553926",
        override_lng: "-0.141587067110009",
      )
      @aviation_house = Place.create!(
        service_slug: @service.slug,
        data_set_version: @service.latest_data_set.version,
        postcode: "WC2B 6SE",
        source_address: "Aviation House",
        override_lat: "51.516960431",
        override_lng: "-0.120586400134",
      )
      @scottish_parliament = Place.create!(
        service_slug: @service.slug,
        data_set_version: @service.latest_data_set.version,
        postcode: "EH99 1SP",
        source_address: "Scottish Parliament",
        override_lat: "55.95439",
        override_lng: "-3.174706",
      )
    end

    should "find places near a point in distance order" do
      places = @service.latest_data_set.places_near(@buckingham_palace.location)
      expected_places = [@buckingham_palace, @aviation_house, @scottish_parliament]
      assert_equal expected_places, places.to_a

      # Check that the distances are reported correctly
      distances_in_miles = [0, 1.42, 332.08]
      places.to_a.zip(distances_in_miles).each do |place, expected_distance|
        assert_in_epsilon expected_distance, place.dis.in(:miles), 0.01
      end
    end

    should "constrain returned points by distance" do
      # Buckingham Palace and Aviation House are 1.4252962055598721 miles apart
      centre = @buckingham_palace.location

      places = @service.latest_data_set.places_near(centre, Distance.miles(1.40))
      assert_equal 1, places.unscope(:select).count

      places = @service.latest_data_set.places_near(centre, Distance.miles(1.45))
      assert_equal 2, places.unscope(:select).count
    end

    should "work when constraining points by a large distance" do
      # Buckingham Palace and the Scottish Parliament are approximately 331 miles apart
      centre = @buckingham_palace.location

      places = @service.latest_data_set.places_near(centre, Distance.miles(330))
      assert_equal 2, places.unscope(:select).count

      places = @service.latest_data_set.places_near(centre, Distance.miles(333))
      assert_equal 3, places.unscope(:select).count
    end

    should "limit number of results" do
      places = @service.latest_data_set.places_near(@buckingham_palace.location, nil, 2)
      assert_equal 2, places.unscope(:select).count
      assert_equal [@buckingham_palace, @aviation_house], places.to_a
    end

    should "limit on both distance and number of results" do
      centre = @buckingham_palace.location

      places = @service.latest_data_set.places_near(centre, Distance.miles(1.40), 2)
      assert_equal 1, places.unscope(:select).count

      places = @service.latest_data_set.places_near(centre, Distance.miles(1.45), 2)
      assert_equal 2, places.unscope(:select).count

      places = @service.latest_data_set.places_near(centre, Distance.miles(400), 2)
      assert_equal 2, places.unscope(:select).count
    end

    should "constrain results to places belonging to the relevant data_set" do
      ds = @service.latest_data_set
      ds2 = @service.data_sets.create!
      service2 = FactoryBot.create(:service)
      FactoryBot.create(:place, service_slug: @service.slug, data_set_version: ds2.version)
      FactoryBot.create(:place, service_slug: service2.slug, data_set_version: service2.latest_data_set.version)

      assert_equal 3, ds.places_near(@buckingham_palace.location).unscope(:select).count
      assert_equal 2, ds.places_near(@buckingham_palace.location, Distance.miles(1.45)).unscope(:select).count
      assert_equal 2, ds.places_near(@buckingham_palace.location, nil, 2).unscope(:select).count
      assert_equal 1, ds.places_near(@buckingham_palace.location, Distance.miles(1.40), 2).unscope(:select).count
      assert_equal 2, ds.places_near(@buckingham_palace.location, Distance.miles(400), 2).unscope(:select).count
    end
  end

  context "places_for_postcode" do
    context "for a 'nearest' service" do
      setup do
        @service = FactoryBot.create(:service)
        @data_set = @service.latest_data_set
        @buckingham_palace = Place.create!(
          service_slug: @service.slug,
          data_set_version: @data_set.version,
          postcode: "SW1A 1AA",
          source_address: "Buckingham Palace, Westminster",
          override_lat: "51.501009611553926",
          override_lng: "-0.141587067110009",
        )
        @aviation_house = Place.create!(
          service_slug: @service.slug,
          data_set_version: @data_set.version,
          postcode: "WC2B 6SE",
          source_address: "Aviation House",
          override_lat: "51.516960431",
          override_lng: "-0.120586400134",
        )
        @scottish_parliament = Place.create!(
          service_slug: @service.slug,
          data_set_version: @data_set.version,
          postcode: "EH99 1SP",
          source_address: "Scottish Parliament",
          override_lat: "55.95439",
          override_lng: "-3.174706",
        )
      end

      should "return places near the postcode's location" do
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])

        expected_location = Point.new(latitude: 51.51695975170424, longitude: -0.12058693935709164)
        @data_set.expects(:places_near).with(expected_location, nil, nil).returns(:some_places)

        assert_equal :some_places, @data_set.places_for_postcode("WC2B 6NH")
      end

      should "pass distance and limit params through to places_near" do
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])

        @data_set.expects(:places_near).with(anything, 14, 5).returns(:some_places)

        assert_equal :some_places, @data_set.places_for_postcode("WC2B 6NH", 14, 5)
      end
    end

    context "for a 'local_authority' service" do
      setup do
        @service = FactoryBot.create(:service, location_match_type: "local_authority")
        @data_set = @service.latest_data_set

        @place1 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "18UK",
          postcode: "EX39 1QS",
          latitude: 51.05318361810428,
          longitude: -4.191071523498792,
          name: "John's Of Appledore",
        )
        @place2 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "18UK",
          postcode: "EX39 1PP",
          latitude: 51.053834,
          longitude: -4.191422,
          name: "Susie's Tea Rooms",
        )
        @place3 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "00AG",
          postcode: "WC2B 6NH",
          latitude: 51.51695975170424,
          longitude: -0.12058693935709164,
          name: "Aviation House",
        )
        @place4 = FactoryBot.create(
          :place,
          service_slug: @service.slug,
          snac: "00AG",
          postcode: "WC1B 5HA",
          latitude: 51.51837458322272,
          longitude: -0.12133586354538765,
          name: "FreeState Coffee",
        )
      end

      should "return places in the same district as the postcode" do
        stub_locations_api_has_location("EX39 1LH", [{ "latitude" => 51.0413792674, "longitude" => -4.23640704632, "local_custodian_code" => 1234 }])
        stub_local_links_manager_has_a_local_authority("county1", country_name: "England", snac: "18UK", local_custodian_code: 1234)
        place_names = @data_set.places_for_postcode("EX39 1LH").map(&:name)
        assert_equal ["John's Of Appledore", "Susie's Tea Rooms"], place_names
      end

      should "return multiple places in order of nearness if there are more than one in the district" do
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164, "local_custodian_code" => 1234 }])
        stub_local_links_manager_has_a_local_authority("county1", country_name: "England", snac: "00AG", local_custodian_code: 1234)

        place_names = @data_set.places_for_postcode("WC2B 6NH").map(&:name)
        assert_equal ["Aviation House", "FreeState Coffee"], place_names
      end

      should "return empty array if no SNAC can be found for the postcode" do
        stub_locations_api_has_location("BT1 5GS", [{ "latitude" => 21.54, "longitude" => -5.93 }])

        assert_equal [], @data_set.places_for_postcode("BT1 5GS").to_a
      end
    end

    context "duplicating a data set" do
      setup do
        DataSet.any_instance.stubs(duplicated: nil)
        service = FactoryBot.create(:service)
        data_set = service.latest_data_set
        @dupe = data_set.duplicate
      end

      should "mark the state of the duplicate data set as 'duplicating'" do
        assert_equal "duplicating", @dupe.state
      end
    end

    context "duplicated data set" do
      setup do
        service = FactoryBot.create(:service)
        data_set = service.latest_data_set
        @dupe = data_set.duplicate
      end

      should "transition from 'duplicating' to 'unarchived' once finished" do
        assert_equal %w[duplicating unarchived], @dupe.previous_changes["state"]
      end
    end
  end

  def create_uploaded_file(contents)
    Tempfile.create do |temp_file|
      temp_file << contents
      temp_file.rewind
      file = ActionDispatch::Http::UploadedFile.new({
        filename: "new.csv",
        type: "text/csv",
        tempfile: temp_file,
      })

      yield file
    end
  end
end
