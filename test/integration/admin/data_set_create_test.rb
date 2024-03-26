require_relative "../../integration_test_helper"
require "gds_api/test_helpers/locations_api"

class DataSetCreateEditTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::LocationsApi

  context "adding a data_set to a service" do
    setup do
      Sidekiq::Testing.inline!
      create_test_user
      @service = FactoryBot.create(:service)
      stub_search_finds_no_govuk_pages
    end

    should "create a data_set from csv and geocode postcodes" do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit "/admin/services/#{@service.id}"
      click_link "Upload new dataset"
      attach_file "Upload a file", fixture_file_path("good_csv.csv")
      click_button "Upload"

      @service.reload
      assert_equal 2, @service.data_sets.count

      ds = @service.latest_data_set
      assert_equal 1, ds.places.count

      place = ds.places.first

      assert_equal 51.59918278577261, place.lat
      assert_equal 0.10033740198112132, place.lng
    end

    should "handle a CSV in a different file encoding" do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit "/admin/services/#{@service.id}"
      click_link "Upload new dataset"
      attach_file "Upload a file", fixture_file_path("encodings/windows-1252.csv")
      click_button "Upload"

      @service.reload
      assert_equal 2, @service.data_sets.count

      ds = @service.latest_data_set
      assert_equal 1, ds.places.count

      place = ds.places.first

      assert_equal 51.59918278577261, place.lat
      assert_equal 0.10033740198112132, place.lng
      assert_equal "1 Stop Instrüction™", place.name
    end

    should "take override lat/lon from csv if present" do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit "/admin/services/#{@service.id}"
      click_link "Upload new dataset"
      attach_file "Upload a file", fixture_file_path("good_csv_with_lat_lng.csv")
      click_button "Upload"

      @service.reload
      assert_equal 2, @service.data_sets.count

      ds = @service.latest_data_set
      assert_equal 1, ds.places.count

      place = ds.places.first

      assert_equal 51.599123456789, place.override_lat
      assert_equal 0.10033123456789, place.override_lng
      assert_equal 51.599123456789, place.lat
      assert_equal 0.10033123456789, place.lng
    end

    should "use postcode if lat/lng in csv is blank" do
      stub_locations_api_has_location("MK45 4RF", [{ "latitude" => 51.96876977095302, "longitude" => -0.4343681877525634 }])
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit "/admin/services/#{@service.id}"
      click_link "Upload new dataset"
      attach_file "Upload a file", fixture_file_path("good_csv_mixed_lat_lng.csv")
      click_button "Upload"

      @service.reload
      assert_equal 2, @service.data_sets.count

      ds = @service.latest_data_set
      assert_equal 2, ds.places.count

      place = ds.places.first
      assert_equal 51.96876977095302, place.lat
      assert_equal(-0.4343681877525634, place.lng)
      assert_nil place.override_lat
      assert_nil place.override_lng

      place = ds.places.last
      assert_equal 51.599123456789, place.lat
      assert_equal 0.10033123456789, place.lng
      assert_equal 51.599123456789, place.override_lat
      assert_equal 0.10033123456789, place.override_lng
    end
  end
end
