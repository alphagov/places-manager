require "test_helper"
require "data_set_csv_presenter"

class DataSetCsvPresenterTest < ActiveSupport::TestCase
  setup do
    @service = FactoryBot.create(:service)
    @data_set = @service.data_sets.create!
    @presenter = DataSetCsvPresenter.new(@data_set)
    @result = @presenter.to_array_for_csv
  end

  def expected_header_row
    %w[
      service_slug
      data_set_version
      name
      source_address
      address1
      address2
      town
      postcode
      access_notes
      general_notes
      url
      email
      phone
      fax
      text_phone
      geocode_error
      gss
      lng
      lat
    ]
  end

  context "presenting an empty dataset" do
    should "contain only a header row" do
      assert_equal [expected_header_row], @result
    end
  end

  context "presenting a dataset with a place" do
    setup do
      @place = FactoryBot.create(
        :place,
        service_slug: @service.slug,
        data_set_version: @data_set.version,
        email: "camden@example.com",
        gss: "00AG",
        override_lng: 0.0,
        override_lat: 1.0,
      )
      @result = @presenter.to_array_for_csv
    end

    should "contain a header row and a results row" do
      expected_place_row = [
        @service.slug,
        @data_set.version,
        @place.name,
        @place.source_address,
        @place.address1,
        @place.address2,
        @place.town,
        @place.postcode,
        @place.access_notes,
        @place.general_notes,
        @place.url,
        @place.email,
        @place.phone,
        @place.fax,
        @place.text_phone,
        @place.geocode_error,
        @place.gss,
        @place.override_lng,
        @place.override_lat,
      ]
      assert_equal 2, @result.size
      assert_equal expected_header_row, @result.first
      assert_equal expected_place_row, @result.last
    end
  end
end
