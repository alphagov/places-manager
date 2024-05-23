require "rails_helper"
require("gds_api/test_helpers/locations_api")

RSpec.describe(PlacesController, type: :controller) do
  include GdsApi::TestHelpers::LocationsApi

  before do
    @service = Service.create!(name: "Important Government Service", slug: "important-government-service")
    @buckingham_palace = Place.create!(service_slug: "important-government-service", data_set_version: @service.data_sets.last.version, postcode: "SW1A 1AA", source_address: "Buckingham Palace, Westminster", override_lat: "51.501009611553926", override_lng: "-0.141587067110009")
    @aviation_house = Place.create!(service_slug: "important-government-service", data_set_version: @service.data_sets.last.version, postcode: "WC2B 6SE", source_address: "Aviation House", override_lat: "51.516960431", override_lng: "-0.120586400134")
    @scottish_parliament = Place.create!(service_slug: "important-government-service", data_set_version: @service.data_sets.last.version, postcode: "EH99 1SP", source_address: "Scottish Parliament", override_lat: "55.95439", override_lng: "-3.174706")
    stub_locations_api_does_not_have_a_postcode("AB11 2CD")
    @utopia = Place.create!(service_slug: "important-government-service", data_set_version: @service.data_sets.last.version, postcode: "AB11 2CD", source_address: "Nowhere")
  end

  it "as a logged in user I can access a non-active data set" do
    as_gds_editor do
      get(:show, params: { id: @service.slug }, format: :json)
      assert_response(:success)
      data = JSON.parse(response.body)
      expect(data["status"]).to(eq("ok"))
      expect(data["contents"]).to(eq("places"))
      expect(data["places"].size).to(eq(4))
    end
  end

  it "can show a JSON representation of places" do
    as_gds_editor do
      get(:show, params: { id: @service.slug }, format: :json)
      assert_response(:success)
      json_data = JSON.parse(response.body)
      place = json_data["places"].find { |p| (p["source_address"] == "Aviation House") }
      expect(place["postcode"]).to(eq("WC2B 6SE"))
      location_hash = { "latitude" => 51.516960431, "longitude" => -0.120586400134 }
      expect(place["location"]).to(eq(location_hash))
    end
  end

  it "can show a JSON representation of a place with no coordinates" do
    as_gds_editor do
      get(:show, params: { id: @service.slug }, format: :json)
      assert_response(:success)
      json_data = JSON.parse(response.body)
      place = json_data["places"].find { |p| (p["source_address"] == "Nowhere") }
      expect(place["location"]).to(be_nil)
    end
  end

  context "with KML" do
    render_views

    it "can show a representation of places" do
      as_gds_editor do
        get(:show, params: { id: @service.slug }, format: :kml)
        assert_response(:success)
        kml_data = Hash.from_xml(response.body)
        expect(kml_data["kml"]["Document"]["Placemark"].size).to(eq(4))
        sorted_places = kml_data["kml"]["Document"]["Placemark"].sort do |a, b|
          (a["address"] <=> b["address"])
        end
        location_points = [nil, RGeo::Geographic.spherical_factory.point(-3.174706, 55.95439), RGeo::Geographic.spherical_factory.point(-0.141587067110009, 51.501009611553926), RGeo::Geographic.spherical_factory.point(-0.120586400134, 51.516960431)]
        sorted_places.zip(location_points) do |placemark, point|
          if point
            expect(placemark["Point"]["coordinates"]).to(eq("#{point.longitude},#{point.latitude},0"))
          else
            expect(placemark["Point"]).to(be_nil)
          end
        end
      end
    end
  end

  it "rescue from GdsApi::HTTPNotFound when no locations for postcode" do
    service = Service.create!(name: "Number Plate Supplier", slug: "number-plate-supplier")
    stub_locations_api_has_no_location("JE4 5TP")
    get(:show, params: { id: service.slug, postcode: "JE4 5TP" }, format: :json)
    assert_response(:bad_request)
    expect(JSON.parse(response.body)["error"]).to(eq("validPostcodeNoLocation"))
  end
end
