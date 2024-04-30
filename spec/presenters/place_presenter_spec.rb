require "rails_helper"
require "gds_api/test_helpers/locations_api"
require "presenters/summary_list_shared_examples"
RSpec.describe(PlacePresenter, type: :model) do
  include GdsApi::TestHelpers::LocationsApi
  include SummaryListSharedExamples

  before do
    stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
    @place = FactoryBot.create(:place, location: nil, postcode: "IG6 3HJ")
    @place.geocode!
    @presenter = PlacePresenter.new(@place)
  end

  context "with a geocode error" do
    it "has an geocode error status tag" do
      expect(@presenter.status_tag).to(match(/Geocode Error/))
    end
  end

  context "with a processed place" do
    before do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
      @place.geocode!
    end

    it "has an good status tag" do
      expect(@presenter.status_tag).to(match(/Good/))
    end
  end
end
