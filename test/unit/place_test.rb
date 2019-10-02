require "test_helper"
require "gds_api/test_helpers/mapit"

class PlaceTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Mapit

  setup do
    mapit_does_not_have_a_postcode("SE1 7DU")
  end

  test "responds to full_address with a compiled address" do
    p = Place.new(name: "Hercules House", address1: "1 Hercules Road", town: "London", postcode: "SE1 7DU")
    assert_equal "1 Hercules Road, London, SE1 7DU, UK", p.full_address
  end

  test "can look up a data set from a place" do
    s = Service.create! slug: "chickens", name: "Chickens!"
    s.data_sets.create! version: 2

    p = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2,
    )
    assert_equal s.data_sets[1], p.data_set
  end

  test "cannot be edited if the data set is active" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    data_set = service.data_sets.create! version: 2

    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2,
    )

    data_set.activate

    place.name = "Aviation House"

    assert_not place.valid?
    assert place.errors.keys.include?(:base)
  end

  test "cannot be edited if the data set is inactive and not the latest version" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    service.data_sets.create! version: 2

    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2,
    )

    service.data_sets.create! version: 3
    place.name = "Aviation House"

    assert_not place.valid?
    assert place.errors.keys.include?(:base)
  end

  test "can be edited if the data set is active but the only changed fields are 'location' or 'geocode_error'" do
    service = Service.create! slug: "chickens", name: "Chickens!"
    service.data_sets.create! version: 2

    place = Place.create!(
      name: "Hercules House",
      source_address: "Blah",
      postcode: "SE1 7DU",
      service_slug: "chickens",
      data_set_version: 2,
    )

    service.data_sets.create! version: 3
    place.location = Point.new(latitude: 51.517356, longitude: -0.120742)
    place.geocode_error = "Error message"

    assert place.valid?
    assert place.save
  end

  context "geocoding" do
    setup do
      @service = FactoryBot.create(:service)
      @data_set = @service.data_sets.create! version: 2
    end

    should "gecode a new place on create" do
      mapit_has_a_postcode("WC2B 6NH", [51.51695975170424, -0.12058693935709164])

      place = Place.create!(
        name: "Aviation House",
        source_address: "Blah",
        postcode: "WC2B 6NH",
        service_slug: @service.slug,
        data_set_version: 2,
      )

      assert_equal 51.51695975170424, place.location.latitude
      assert_equal(-0.12058693935709164, place.location.longitude)
    end

    should "not overwrite location if created with a lat/lon" do
      place = Place.create!(
        name: "Aviation House",
        source_address: "Blah",
        postcode: "WC2B 6NH",
        override_lat: 51.501,
        override_lng: -0.123,
        service_slug: @service.slug,
        data_set_version: 2,
      )

      assert_equal 51.501, place.location.latitude
      assert_equal(-0.123, place.location.longitude)

      assert_nil place.geocode_error
    end

    should "not overwrite location if created with a location" do
      place = Place.create!(
        name: "Aviation House",
        source_address: "Blah",
        postcode: "WC2B 6NH",
        location: Point.new(latitude: 51.501, longitude: -0.123),
        service_slug: @service.slug,
        data_set_version: 2,
      )

      assert_equal 51.501, place.location.latitude
      assert_equal(-0.123, place.location.longitude)

      assert_nil place.geocode_error
    end

    should "gecode postcode when postcode is changed" do
      mapit_has_a_postcode("SE1 7DU", [51.498241853641055, -0.11354773400359928])
      mapit_has_a_postcode("WC2B 6NH", [51.51695975170424, -0.12058693935709164])

      place = Place.create!(
        name: "Hercules House",
        source_address: "Blah",
        postcode: "SE1 7DU",
        service_slug: @service.slug,
        data_set_version: 2,
      )

      assert_equal 51.498241853641055, place.location.latitude
      assert_equal(-0.11354773400359928, place.location.longitude)

      place.postcode = "WC2B 6NH"

      assert place.save

      assert_equal 51.51695975170424, place.location.latitude
      assert_equal(-0.12058693935709164, place.location.longitude)
    end
  end

  context "dis attribute wrapper" do
    setup do
      @place = FactoryBot.create(:place, override_lat: 53.105491, override_lng: -2.017493)
    end

    should "return nil when no geo_near_distance available" do
      assert_nil @place.dis
    end

    should "return a distance object for the geo_near_distance if available" do
      p = Place.geo_near([-2.01, 53.1]).first

      assert_in_epsilon 0.642566, p.dis.in(:miles), 0.001
    end
  end
end
