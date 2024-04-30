require "rails_helper"

RSpec.describe(Place, type: :model) do
  include GdsApi::TestHelpers::LocationsApi

  before { stub_locations_api_does_not_have_a_postcode("SE1 7DU") }

  it "responds to full_address with a compiled address" do
    p = Place.new(name: "Hercules House", address1: "1 Hercules Road", town: "London", postcode: "SE1 7DU")
    expect(p.full_address).to(eq("1 Hercules Road, London, SE1 7DU, UK"))
  end

  it "can look up a data set from a place" do
    s = Service.create!(slug: "chickens", name: "Chickens!")
    s.data_sets.create!(version: 2)
    p = Place.create!(name: "Hercules House", source_address: "Blah", postcode: "SE1 7DU", service_slug: "chickens", data_set_version: 2)
    expect(p.data_set).to(eq(s.data_sets[1]))
  end

  it "cannot be edited if the data set is active" do
    service = Service.create!(slug: "chickens", name: "Chickens!")
    data_set = service.data_sets.create!(version: 2)
    place = Place.create!(name: "Hercules House", source_address: "Blah", postcode: "SE1 7DU", service_slug: "chickens", data_set_version: 2)
    data_set.activate
    place.name = "Aviation House"
    expect(place.valid?).to eq(false)
    expect(place.errors[:base].present?).to(eq(true))
  end

  it "cannot be edited if the data set is inactive and not the latest version" do
    service = Service.create!(slug: "chickens", name: "Chickens!")
    service.data_sets.create!(version: 2)
    place = Place.create!(name: "Hercules House", source_address: "Blah", postcode: "SE1 7DU", service_slug: "chickens", data_set_version: 2)
    service.data_sets.create!(version: 3)
    place.name = "Aviation House"
    expect(place.valid?).to eq(false)
    expect(place.errors[:base].present?).to(eq(true))
  end

  it "can be edited if the data set is active but the only changed fields are 'location' or 'geocode_error'" do
    service = Service.create!(slug: "chickens", name: "Chickens!")
    service.data_sets.create!(version: 2)
    place = Place.create!(name: "Hercules House", source_address: "Blah", postcode: "SE1 7DU", service_slug: "chickens", data_set_version: 2)
    service.data_sets.create!(version: 3)
    place.location = "POINT(-0.120742 51.517356)"
    place.geocode_error = "Error message"
    expect(place.valid?).to(eq(true))
    expect(place.save).to(be_truthy)
  end

  describe "geocoding" do
    before do
      @service = FactoryBot.create(:service)
      @data_set = @service.data_sets.create!(version: 2)
    end

    it "geocodes a new place on create" do
      stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])
      place = Place.create!(name: "Aviation House", source_address: "Blah", postcode: "WC2B 6NH", service_slug: @service.slug, data_set_version: 2)

      expect(place.location.latitude).to eq(51.51695975170424)
      expect(place.location.longitude).to eq(-0.12058693935709164)
      expect(place.geocode_error).to be nil
    end

    it "gracefully handles location-api failures" do
      stub_locations_api_error("WC2B 6NH")
      place = Place.create!(name: "Aviation House", source_address: "Blah", postcode: "WC2B 6NH", service_slug: @service.slug, data_set_version: 2)

      expect(place.geocode_error).to match(/Error geocoding place WC2B 6NH/)
    end

    it "does not overwrite location if created with a lat/lon" do
      place = Place.create!(name: "Aviation House", source_address: "Blah", postcode: "WC2B 6NH", override_lat: 51.501, override_lng: -0.123, service_slug: @service.slug, data_set_version: 2)

      expect(place.location.latitude).to(eq(51.501))
      expect(place.location.longitude).to(eq(-0.123))
      expect(place.geocode_error).to(be_nil)
    end

    it "does not overwrite location if created with a location" do
      place = Place.create!(name: "Aviation House", source_address: "Blah", postcode: "WC2B 6NH", location: "POINT(-0.123 51.501)", service_slug: @service.slug, data_set_version: 2)

      expect(place.location.latitude).to(eq(51.501))
      expect(place.location.longitude).to(eq(-0.123))
      expect(place.geocode_error).to(be_nil)
    end

    it "geocodes postcode when postcode is changed" do
      stub_locations_api_has_location("SE1 7DU", [{ "latitude" => 51.498241853641055, "longitude" => -0.11354773400359928 }])
      stub_locations_api_has_location("WC2B 6NH", [{ "latitude" => 51.51695975170424, "longitude" => -0.12058693935709164 }])

      place = Place.create!(name: "Hercules House", source_address: "Blah", postcode: "SE1 7DU", service_slug: @service.slug, data_set_version: 2)
      expect(place.location.latitude).to(eq(51.498241853641055))
      expect(place.location.longitude).to(eq(-0.11354773400359928))

      place.postcode = "WC2B 6NH"
      expect(place.save).to(be_truthy)
      expect(place.location.latitude).to(eq(51.51695975170424))
      expect(place.location.longitude).to(eq(-0.12058693935709164))
    end
  end

  context "dis attribute wrapper" do
    before do
      @place = FactoryBot.create(:place, override_lat: 53.105491, override_lng: -2.017493)
    end

    it "returns nil when no distance available" do
      expect(@place.dis).to(be_nil)
    end

    it "returns a distance object for the distance if available" do
      location = RGeo::Geographic.spherical_factory.point(-2.01, 53.1)
      loc_string = "'SRID=4326;POINT(#{location.longitude} #{location.latitude})'::geometry"
      query = Place.all.reorder(Arel.sql("location <-> #{loc_string}"))
      query = query.select(Arel.sql("places.*, ST_Distance(location, #{loc_string}) as distance"))
      p = query.first
      assert_in_epsilon(0.491351, p.dis.in(:miles), 0.001)
    end
  end
end
