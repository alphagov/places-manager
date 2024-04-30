require "rails_helper"
require "csv"
require "gds_api/test_helpers/local_links_manager"
require "gds_api/test_helpers/locations_api"

RSpec.describe("Places API", type: :integration) do
  include GdsApi::TestHelpers::LocalLinksManager
  include GdsApi::TestHelpers::LocationsApi
  include Capybara::DSL

  context "Requesting the full data set" do
    before do
      @service = FactoryBot.create(:service)
      @data_set1 = @service.active_data_set
      @data_set2 = @service.data_sets.create!
      @place_1a = FactoryBot.create(:place, service_slug: @service.slug, data_set_version: @data_set1.version, latitude: 51.613314, longitude: -0.158278, name: "Town Hall")
      @place_1b = FactoryBot.create(:place, service_slug: @service.slug, data_set_version: @data_set1.version, latitude: 51.500728, longitude: -0.124626, name: "Palace of Westminster")
      @place_2a = FactoryBot.create(:place, service_slug: @service.slug, data_set_version: @data_set2.version, latitude: 51.613314, longitude: -0.158278, name: "Town Hall 2")
      @place_2b = FactoryBot.create(:place, service_slug: @service.slug, data_set_version: @data_set2.version, latitude: 51.500728, longitude: -0.124626, name: "Palace of Westminster 2")
      @data_set2.activate
    end

    it "returns all places for the current dataset as JSON" do
      visit("/places/#{@service.slug}.json")
      expect(page.response_headers["Content-Type"]).to(eq("application/json; charset=utf-8"))
      data = JSON.parse(page.body)
      expect(data["places"].map { |p| p["name"] }).to(eq(["Palace of Westminster 2", "Town Hall 2"]))
    end

    it "returns all places as CSV" do
      visit("/places/#{@service.slug}.csv")
      expect(page.response_headers["Content-Type"]).to(eq("text/csv"))
      data = CSV.new(page.body, headers: true).read
      expect(data.map { |p| p["name"] }).to(eq(["Palace of Westminster 2", "Town Hall 2"]))
    end

    it "returns all places as KML" do
      visit("/places/#{@service.slug}.kml")
      expect(page.response_headers["Content-Type"]).to(eq("application/vnd.google-earth.kml+xml; charset=utf-8"))
      data = Nokogiri::XML.parse(page.body)
      names = data.xpath("//xmlns:Placemark/xmlns:name").map(&:text)
      expect(names).to(eq(["Palace of Westminster 2", "Town Hall 2"]))
    end

    context "requesting a specific version" do
      before do
        stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place").to_return(status: 200, body: { results: [] }.to_json, headers: {})
      end

      it "returns requested version when logged in" do
        GDS::SSO.test_user = FactoryBot.create(:user)
        stub_organisations_test_department
        visit("/admin")
        visit("/places/#{@service.slug}.json?version=#{@data_set1.to_param}")
        data = JSON.parse(page.source)
        expect(data["places"].map { |p| p["name"] }).to(eq(["Palace of Westminster", "Town Hall"]))
      end

      it "ignores requested version and return active version when not logged in" do
        visit("/places/#{@service.slug}.json?version=#{@data_set1.to_param}")
        data = JSON.parse(page.source)
        expect(data["places"].map { |p| p["name"] }).to(eq(["Palace of Westminster 2", "Town Hall 2"]))
      end
    end
  end

  describe "Filtering places by location" do
    context "for a geo-distance service" do
      before do
        @service = FactoryBot.create(:service)
        @place1 = FactoryBot.create(:place, service_slug: @service.slug, latitude: 51.613314, longitude: -0.158278, name: "Town Hall")
        @place2 = FactoryBot.create(:place, service_slug: @service.slug, latitude: 51.500728, longitude: -0.124626, name: "Palace of Westminster")
      end

      it "returns places near the given postcode" do
        stub_locations_api_has_location("N11 3HD", [{ "latitude" => 51.61727978727051, "longitude" => -0.14946662305980687 }])
        stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])
        visit("/places/#{@service.slug}.json?postcode=N11+3HD")
        data = JSON.parse(page.body)
        expect(data["places"].length).to(eq(2))
        expect(data["places"][0]["name"]).to(eq(@place1.name))
        visit("/places/#{@service.slug}.json?postcode=WC2B+6NH")
        data = JSON.parse(page.body)
        expect(data["places"].length).to(eq(2))
        expect(data["places"][0]["name"]).to(eq(@place2.name))
      end

      it "returns places near the given lat/lng" do
        visit("/places/#{@service.slug}.json?lat=51.617&lng=-0.149")
        data = JSON.parse(page.body)
        expect(data["places"].length).to(eq(2))
        expect(data["places"][0]["name"]).to(eq(@place1.name))
        visit("/places/#{@service.slug}.json?lat=51.517&lng=-0.120")
        data = JSON.parse(page.body)
        expect(data["places"].length).to(eq(2))
        expect(data["places"][0]["name"]).to(eq(@place2.name))
      end

      it "returns a 400 for a missing postcode" do
        stub_locations_api_does_not_have_a_postcode("N11 3QQ")
        visit("/places/#{@service.slug}.json?postcode=N11+3QQ")
        expect(page.status_code).to(eq(400))
      end

      it "returns a 400 for an invalid postcode" do
        stub_locations_api_does_not_have_a_postcode("N1")
        visit("/places/#{@service.slug}.json?postcode=N1")
        expect(page.status_code).to(eq(400))
      end
    end

    context "for an authority-bounded service" do
      before do
        @service = FactoryBot.create(:service, location_match_type: "local_authority")
        @place1 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345678", latitude: 51.0519276, longitude: -4.1907002, name: "John's Of Appledore")
        @place2 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345678", latitude: 51.053834, longitude: -4.191422, name: "Susie's Tea Rooms")
        @place3 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345679", latitude: 51.500728, longitude: -0.124626, name: "Palace of Westminster")
        @place4 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345679", latitude: 51.51837458322272, longitude: -0.12133586354538765, name: "FreeState Coffee")
        @place5 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345680", latitude: 51.0542, longitude: -4.19096, name: "The Coffee Cabin")
        @place6 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E12345680", latitude: 51.05289, longitude: -4.19111, name: "The Quay Restaurant and Gallery")
        @place7 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E060000063", latitude: 51.0542, longitude: -4.19096, name: "Cumbrian Cabin")
        @place8 = FactoryBot.create(:place, service_slug: @service.slug, gss: "E060000063", latitude: 51.05289, longitude: -4.19111, name: "Cumbrian Gallery")
      end

      it "returns empty array if there are no places in the corresponding authority" do
        stub_locations_api_has_location("N11 3HD", [{ "latitude" => 51.61727978727051, "longitude" => -0.14946662305980687, "local_custodian_code" => 1234 }])
        stub_local_links_manager_does_not_have_a_custodian_code(1234)
        visit("/places/#{@service.slug}.json?postcode=N11+3HD")
        data = JSON.parse(page.body)
        expect(data["status"]).to(eq("ok"))
        expect(data["places"]).to(eq([]))
      end

      it "returns a 400 for an invalid postcode" do
        stub_locations_api_does_not_have_a_postcode("N11 3QQ")
        visit("/places/#{@service.slug}.json?postcode=N11+3QQ")
        expect(page.status_code).to(eq(400))
      end

      context "when a postcode covers multiple authorities" do
        before do
          stub_locations_api_has_location("CH25 9BJ", [{ "address" => "House 1", "local_custodian_code" => "1" }, { "address" => "House 2", "local_custodian_code" => "2" }, { "address" => "House 3", "local_custodian_code" => "3" }])
          stub_local_links_manager_has_a_local_authority("achester", local_custodian_code: 1, gss: "E12345678")
          stub_local_links_manager_has_a_local_authority("beechester", local_custodian_code: 2, gss: "E12345679")
          stub_local_links_manager_has_a_local_authority("ceechester", local_custodian_code: 3, gss: "E12345680")
          stub_local_links_manager_does_not_have_an_authority("deechester")
        end

        it "returns an address array if the postcode exists in multiple authorities" do
          visit("/places/#{@service.slug}.json?postcode=CH25+9BJ")
          data = JSON.parse(page.body)
          expect(data["status"]).to(eq("address-information-required"))
          expect(data["contents"]).to(eq("addresses"))
          expect(data["addresses"][0]["address"]).to(eq("House 1"))
          expect(data["addresses"][0]["local_authority_slug"]).to(eq("achester"))
          expect(data["addresses"].count).to(eq(3))
        end

        it "returns only search results within an authority if the local_authority_slug is specified" do
          visit("/places/#{@service.slug}.json?postcode=CH25+9BJ&local_authority_slug=beechester")
          data = JSON.parse(page.body)
          expect(data["status"]).to(eq("ok"))
          expect(data["contents"]).to(eq("places"))
          expect(data["places"].count).to(eq(2))
          expect(data["places"][0]["name"]).to(eq("Palace of Westminster"))
          expect(data["places"][1]["name"]).to(eq("FreeState Coffee"))
        end

        it "returns 400 valid postcode if the local_authority_slug is specified but is not valid" do
          visit("/places/#{@service.slug}.json?postcode=CH25+9BJ&local_authority_slug=deechester")
          data = JSON.parse(page.body)
          expect(page.status_code).to(eq(400))
          expect(data["error"]).to(eq("validPostcodeNoLocation"))
        end
      end

      context "when the service is bounded to districts" do
        before do
          @service.update(local_authority_hierarchy_match_type: Service::LOCAL_AUTHORITY_DISTRICT_MATCH)
        end

        it "returns the district places in order of nearness, not the county ones for postcodes in a county+district council hierarchy" do
          stub_locations_api_has_location("EX39 1QS", [{ "latitude" => 51.05318361810428, "longitude" => -4.191071523498792, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_district_and_county_local_authority("my-district", "my-county", district_gss: "E12345678", county_gss: "E12345680", local_custodian_code: 1234)
          visit("/places/#{@service.slug}.json?postcode=EX39+1QS")
          data = JSON.parse(page.body)
          expect(data["places"].length).to(eq(2))
          expect(data["places"][0]["name"]).to(eq(@place2.name))
          expect(data["places"][1]["name"]).to(eq(@place1.name))
        end

        it "returns all the places in order of nearness for postcodes not in a county+district council hierarchy" do
          stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_local_authority("county1", country_name: "England", gss: "E12345679", local_custodian_code: 1234)
          visit("/places/#{@service.slug}.json?postcode=WC2B+6NH")
          data = JSON.parse(page.body)
          expect(data["places"].length).to(eq(2))
          expect(data["places"][0]["name"]).to(eq(@place4.name))
          expect(data["places"][1]["name"]).to(eq(@place3.name))
        end
      end

      context "when the service is bounded to counties" do
        before do
          @service.update(local_authority_hierarchy_match_type: Service::LOCAL_AUTHORITY_COUNTY_MATCH)
        end

        it "only returns the county results in order of nearness, not the district ones for postcodes in a county+district council hierarchy" do
          stub_locations_api_has_location("EX39 1QS", [{ "latitude" => 51.05318361810428, "longitude" => -4.191071523498792, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_district_and_county_local_authority("my-district", "my-county", district_gss: "E12345678", county_gss: "E12345680", local_custodian_code: 1234)
          visit("/places/#{@service.slug}.json?postcode=EX39+1QS")
          data = JSON.parse(page.body)
          expect(data["places"].length).to(eq(2))
          expect(data["places"][0]["name"]).to(eq(@place6.name))
          expect(data["places"][1]["name"]).to(eq(@place5.name))
        end

        it "returns all the places in order of nearness for postcodes not in a county+district council hierarchy" do
          stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164, "local_custodian_code" => 1234 }])
          stub_local_links_manager_has_a_local_authority("county1", country_name: "England", gss: "E12345679", local_custodian_code: 1234)
          visit("/places/#{@service.slug}.json?postcode=WC2B+6NH")
          data = JSON.parse(page.body)
          expect(data["places"].length).to(eq(2))
          expect(data["places"][0]["name"]).to(eq(@place4.name))
          expect(data["places"][1]["name"]).to(eq(@place3.name))
        end
      end
    end
  end
end
