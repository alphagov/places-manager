require "rails_helper"
require "gds_api/test_helpers/locations_api"
require "presenters/table_presenter_shared_examples"

RSpec.describe(PlacesTablePresenter, type: :model) do
  include GdsApi::TestHelpers::LocationsApi
  include TablePresenterSharedExamples

  before do
    stub_locations_api_has_location("IG6 3HJ", [{ "latitude" => 51.59918278577261, "longitude" => 0.10033740198112132 }])
    @service = FactoryBot.create(:service)
    @data_set = @service.data_sets.create!(data_file: File.open(fixture_file_path("good_csv.csv")))
    @data_set.process_csv_data
    @presenter = PlacesTablePresenter.new(@data_set, @data_set.places, fake_view_context)
  end
end
