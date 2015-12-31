require 'test_helper'
require 'data_set_csv_presenter'

class DataSetCsvPresenterTest < ActiveSupport::TestCase
  setup do
    @service = FactoryGirl.create(:service)
    @data_set = @service.data_sets.create!
    @presenter = DataSetCsvPresenter.new(@data_set)
    @result = @presenter.to_array_for_csv
  end

  def expected_header_row
    [
      "name",
      "address1",
      "address2",
      "town",
      "postcode",
      "access_notes",
      "general_notes",
      "url",
      "lat",
      "lng",
      "phone",
      "fax",
      "text_phone",
    ]
  end

  context "presenting an empty dataset" do
    should "contain only a header row" do
      assert_equal [expected_header_row], @result
    end
  end

  context "presenting a dataset with a place" do
    setup do
      @place = FactoryGirl.create(:place, service_slug: @service.slug,
                                  data_set_version: @data_set.version,
                                  override_lng: 0.0, override_lat: 1.0)
      @result = @presenter.to_array_for_csv
    end

    should "contain a header row and a results row" do
      expected_place_row = [
        @place.name,
        @place.address1,
        @place.address2,
        @place.town,
        @place.postcode,
        @place.access_notes,
        @place.general_notes,
        @place.url,
        @place.override_lat,
        @place.override_lng,
        @place.phone,
        @place.fax,
        @place.text_phone,
      ]
      assert_equal 2, @result.size
      assert_equal expected_header_row, @result.first
      assert_equal expected_place_row, @result.last
    end
  end
end
