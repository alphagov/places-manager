require "rails_helper"
require "gds_api/test_helpers/locations_api"

RSpec.describe("DataSetCreateEditTest", type: :integration) do
  include GdsApi::TestHelpers::LocationsApi
  include Capybara::DSL

  context "adding a data_set to a service" do
    before do
      Sidekiq::Testing.inline!
      @service = FactoryBot.create(:service)
      GDS::SSO.test_user = FactoryBot.create(:user)
      stub_search_finds_no_govuk_pages
    end

    it "creates a data_set from csv and geocode postcodes" do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit("/admin/services/#{@service.id}")
      click_link("Upload new data set")
      attach_file("Upload a file", fixture_file_path("good_csv.csv"))
      click_button("Upload")

      @service.reload
      expect(@service.data_sets.count).to(eq(2))
      ds = @service.latest_data_set
      expect(ds.places.count).to(eq(1))
      place = ds.places.first
      expect(place.lat).to(eq(51.59918278577261))
      expect(place.lng).to(eq(0.10033740198112132))
    end

    it "handles a CSV in a different file encoding" do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit("/admin/services/#{@service.id}")
      click_link("Upload new data set")
      attach_file("Upload a file", fixture_file_path("encodings/windows-1252.csv"))
      click_button("Upload")

      @service.reload
      expect(@service.data_sets.count).to(eq(2))
      ds = @service.latest_data_set
      expect(ds.places.count).to(eq(1))
      place = ds.places.first
      expect(place.lat).to(eq(51.59918278577261))
      expect(place.lng).to(eq(0.10033740198112132))
      expect(place.name).to(eq("1 Stop Instr\u00FCction\u2122"))
    end

    it "takes override lat/lon from csv if present" do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit("/admin/services/#{@service.id}")
      click_link("Upload new data set")
      attach_file("Upload a file", fixture_file_path("good_csv_with_lat_lng.csv"))
      click_button("Upload")

      @service.reload
      expect(@service.data_sets.count).to(eq(2))
      ds = @service.latest_data_set
      expect(ds.places.count).to(eq(1))
      place = ds.places.first
      expect(place.override_lat).to(eq(51.599123456789))
      expect(place.override_lng).to(eq(0.10033123456789))
      expect(place.lat).to(eq(51.599123456789))
      expect(place.lng).to(eq(0.10033123456789))
    end

    it "uses postcode if lat/lng in csv is blank" do
      stub_locations_api_has_location("MK45 4RF", [{ "latitude" => 51.96876977095302, "longitude" => -0.4343681877525634 }])
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])

      visit("/admin/services/#{@service.id}")
      click_link("Upload new data set")
      attach_file("Upload a file", fixture_file_path("good_csv_mixed_lat_lng.csv"))
      click_button("Upload")

      @service.reload
      expect(@service.data_sets.count).to(eq(2))
      ds = @service.latest_data_set
      expect(ds.places.count).to(eq(2))
      place = ds.places.first
      expect(place.lat).to(eq(51.96876977095302))
      expect(place.lng).to(eq(-0.4343681877525634))
      expect(place.override_lat).to(be_nil)
      expect(place.override_lng).to(be_nil)
      place = ds.places.last
      expect(place.lat).to(eq(51.599123456789))
      expect(place.lng).to(eq(0.10033123456789))
      expect(place.override_lat).to(eq(51.599123456789))
      expect(place.override_lng).to(eq(0.10033123456789))
    end
  end
end
