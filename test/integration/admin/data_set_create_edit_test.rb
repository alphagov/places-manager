# encoding: utf-8

require_relative '../../integration_test_helper'
require 'gds_api/test_helpers/mapit'

class DataSetCreateEditTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::Mapit

  context "adding a data_set to a service" do
    setup do
      create_test_user
      @service = FactoryGirl.create(:service)
    end

    should "create a data_set from csv and geocode postcodes" do
      mapit_has_a_postcode("IG6 3HJ", [51.59918278577261, 0.10033740198112132])

      visit "/admin/services/#{@service.id}"

      within "#new-data" do
        attach_file "Data file", fixture_file_path("good_csv.csv")
        click_button "Create Data set"
      end

      run_all_delayed_jobs

      @service.reload
      assert_equal 2, @service.data_sets.count

      ds = @service.latest_data_set
      assert_equal 1, ds.places.count

      place = ds.places.first

      assert_equal 51.59918278577261, place.lat
      assert_equal 0.10033740198112132, place.lng
    end

    should "handle a CSV in a different file encoding" do
      mapit_has_a_postcode("IG6 3HJ", [51.59918278577261, 0.10033740198112132])

      visit "/admin/services/#{@service.id}"

      within "#new-data" do
        attach_file "Data file", fixture_file_path("encodings/windows-1252.csv")
        click_button "Create Data set"
      end

      run_all_delayed_jobs

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
      mapit_has_a_postcode("IG6 3HJ", [51.59918278577261, 0.10033740198112132])

      visit "/admin/services/#{@service.id}"

      within "#new-data" do
        attach_file "Data file", fixture_file_path("good_csv_with_lat_lng.csv")
        click_button "Create Data set"
      end

      run_all_delayed_jobs

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
      mapit_has_a_postcode("MK45 4RF", [51.96876977095302, -0.4343681877525634])
      mapit_has_a_postcode("IG6 3HJ", [51.59918278577261, 0.10033740198112132])

      visit "/admin/services/#{@service.id}"

      within "#new-data" do
        attach_file "Data file", fixture_file_path("good_csv_mixed_lat_lng.csv")
        click_button "Create Data set"
      end

      run_all_delayed_jobs

      @service.reload
      assert_equal 2, @service.data_sets.count

      ds = @service.latest_data_set
      assert_equal 2, ds.places.count

      place = ds.places.first
      assert_equal 51.96876977095302, place.lat
      assert_equal -0.4343681877525634, place.lng
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
