require "rails_helper"
require "gds_api/test_helpers/locations_api"
require "presenters/summary_list_shared_examples"

RSpec.describe(DataSetPresenter, type: :model) do
  include GdsApi::TestHelpers::LocationsApi
  include SummaryListSharedExamples

  before do
    @service = FactoryBot.create(:service)
    @data_set = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
    @presenter = DataSetPresenter.new(@data_set)
  end

  context "presenting a processing data set" do
    it "has an inactive use tag" do
      expect(@presenter.use_tag).to(match(/Inactive/))
    end

    it "has a processing status" do
      expect(@presenter.status_tag).to(match(/Places data is currently being processed/))
    end

    it "shows that there are currently no places" do
      expect(@presenter.places_info).to(eq("0"))
    end
  end

  context "presenting an inactive data set" do
    before do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
      @data_set.process_csv_data
    end

    it "has an inactive use tag" do
      expect(@presenter.use_tag).to(match(/Inactive/))
    end

    it "has a ready status" do
      expect(@presenter.status_tag).to(match(/Ready/))
    end

    it "shows places" do
      expect(@presenter.places_info).to(eq("1"))
    end
  end

  context "presenting a data set with geocoding errors" do
    before do
      stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
      @data_set.process_csv_data
    end

    it "shows places" do
      expect(@presenter.places_info).to(eq("1 (1 with geocode errors)"))
    end
  end

  context "presenting an active data set" do
    before do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
      @data_set.process_csv_data
      @data_set.activate
    end

    it "has an active use tag" do
      expect(@presenter.use_tag).to(match(/Active/))
    end
  end
end
