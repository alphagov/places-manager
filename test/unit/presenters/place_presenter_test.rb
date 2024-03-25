require "test_helper"
require "gds_api/test_helpers/locations_api"
require "unit/presenters/summary_list_shared_examples"

class PlacePresenterTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LocationsApi
  include SummaryListSharedExamples

  setup do
    stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
    @place = FactoryBot.create(:place, location: nil, postcode: "IG6 3HJ")
    @place.geocode!
    @presenter = PlacePresenter.new(@place)
  end

  context "with a geocode error" do
    should "have an geocode error status tag" do
      assert_match(/Geocode Error/, @presenter.status_tag)
    end
  end

  context "with a processed place" do
    setup do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
      @place.geocode!
    end

    should "have an good status tag" do
      assert_match(/Good/, @presenter.status_tag)
    end
  end
end
