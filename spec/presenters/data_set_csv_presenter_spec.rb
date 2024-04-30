require "rails_helper"

RSpec.describe(DataSetCsvPresenter, type: :model) do
  before do
    @service = FactoryBot.create(:service)
    @data_set = @service.data_sets.create!
    @presenter = DataSetCsvPresenter.new(@data_set)
    @result = @presenter.to_array_for_csv
  end

  def expected_header_row
    %w[service_slug data_set_version name source_address address1 address2 town postcode access_notes general_notes url email phone fax text_phone geocode_error gss lng lat]
  end

  context "presenting an empty data set" do
    it "contain only a header row" do
      expect(@result).to(eq([expected_header_row]))
    end
  end

  context "presenting a data set with a place" do
    before do
      @place = FactoryBot.create(:place, service_slug: @service.slug, data_set_version: @data_set.version, email: "camden@example.com", gss: "00AG", override_lng: 0.0, override_lat: 1.0)
      @result = @presenter.to_array_for_csv
    end

    it "contain a header row and a results row" do
      expected_place_row = [@service.slug, @data_set.version, @place.name, @place.source_address, @place.address1, @place.address2, @place.town, @place.postcode, @place.access_notes, @place.general_notes, @place.url, @place.email, @place.phone, @place.fax, @place.text_phone, @place.geocode_error, @place.gss, @place.override_lng, @place.override_lat]
      expect(@result.size).to(eq(2))
      expect(@result.first).to(eq(expected_header_row))
      expect(@result.last).to(eq(expected_place_row))
    end
  end
end
