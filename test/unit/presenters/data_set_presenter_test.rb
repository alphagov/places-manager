require "test_helper"
require "gds_api/test_helpers/locations_api"
require "unit/presenters/summary_list_shared_examples"

class DataSetPresenterTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LocationsApi
  include SummaryListSharedExamples

  setup do
    @service = FactoryBot.create(:service)
    @data_set =  @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
    @presenter = DataSetPresenter.new(@data_set)
  end

  context "presenting a processing dataset" do
    should "have an inactive use tag" do
      assert_match(/Inactive/, @presenter.use_tag)
    end

    should "have a processing status" do
      assert_match(/Places data is currently being processed/, @presenter.status_tag)
    end

    should "show that there are currently no places" do
      assert_equal("0", @presenter.places_info)
    end
  end

  context "presenting an inactive dataset" do
    setup do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
      @data_set.process_csv_data
    end

    should "have an inactive use tag" do
      assert_match(/Inactive/, @presenter.use_tag)
    end

    should "have a ready status" do
      assert_match(/Ready/, @presenter.status_tag)
    end

    should "show places" do
      assert_equal("1", @presenter.places_info)
    end
  end

  context "presenting a dataset with geocoding errors" do
    setup do
      stub_locations_api_does_not_have_a_postcode("IG6 3HJ")
      @data_set.process_csv_data
    end

    should "show places" do
      assert_equal("1 (1 with geocode errors)", @presenter.places_info)
    end
  end

  context "presenting an active dataset" do
    setup do
      stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
      @data_set.process_csv_data
      @data_set.activate
    end

    should "have an active use tag" do
      assert_match(/Active/, @presenter.use_tag)
    end
  end
end
