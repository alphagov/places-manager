require "rails_helper"

RSpec.describe(DataSetCsvPresenter, type: :model) do
  subject(:data_set_csv_presenter) { described_class.new(data_set) }
  let(:service) { FactoryBot.create(:service) }
  let(:data_set) { service.data_sets.create! }
  let(:result) { data_set_csv_presenter.to_csv }

  def expected_header_row
    "service_slug,data_set_version,name,source_address,address1,address2,town,postcode,access_notes,general_notes,url,email,phone,fax,text_phone,geocode_error,gss,lng,lat,map_marker_colour,map_marker_symbol"
  end

  context "presenting an empty data set" do
    it "contain only a header row" do
      expect(result.chomp).to(eq(expected_header_row))
    end
  end

  context "presenting a data set with a place" do
    let(:place) { FactoryBot.create(:place, service_slug: service.slug, data_set_version: data_set.version, email: "camden@example.com", gss: "00AG", override_lng: 0.0, override_lat: 1.0, map_marker_colour: "red", map_marker_symbol: "circle") }

    it "contain a header row and a results row" do
      expected_place_row = "#{service.slug},2,CosaNostra Pizza #3569,\"#{place.address1}, Los Angeles, WC2B 6NH\",#{place.address1},,Los Angeles,WC2B 6NH,,,,camden@example.com,01234 567890,,,,00AG,0.0,1.0,red,circle"

      expect(result.split("\n").size).to(eq(2))
      expect(result.split("\n").first).to(eq(expected_header_row))
      expect(result.split("\n").last).to(eq(expected_place_row))
    end
  end
end
