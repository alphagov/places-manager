require 'test_helper'
require 'mapit_api'

class MockResponse
  attr_reader :code, :to_hash
  def initialize(code, data)
    @code = code
    @to_hash = data
  end
end

class MapitApiTest < ActiveSupport::TestCase
  context "payload" do
    setup do
      @areas = {
        123 => { "id" => 123, "name" => "Westminster City Council", "country_name" => "England", "type" => "LBO" },
        234 => { "id" => 234, "name" => "London", "country_name" => "England", "type" => "EUR" }
      }
    end
    context "for an AreasByTypeResponse" do
      should "return code and areas attributes in a hash" do
        api_response = MockResponse.new(200, @areas)
        response = MapitApi::AreasByTypeResponse.new(api_response)

        assert_equal 200, response.payload[:code]
        assert_equal 123, response.payload[:areas].first["id"]
        assert_equal "Westminster City Council", response.payload[:areas].first["name"]
        assert_equal 234, response.payload[:areas].last["id"]
        assert_equal "London", response.payload[:areas].last["name"]
      end
    end
    context "for a RegionsResponse" do
      should "prepend England as a region" do
        api_response = MockResponse.new(200, @areas)
        response = MapitApi::RegionsResponse.new(api_response)

        assert_equal 200, response.payload[:code]
        assert_equal "England", response.payload[:areas].first["name"]
        assert_equal "Westminster City Council", response.payload[:areas].second["name"]
        assert_equal "London", response.payload[:areas].last["name"]
      end
      should "normalise region names" do
        @areas[444] = { "name" => "Eastern" }
        api_response = MockResponse.new(200, @areas)
        response = MapitApi::RegionsResponse.new(api_response)

        assert_equal 200, response.payload[:code]
        assert_equal "East of England", response.payload[:areas].last["name"]
      end
    end
    context "payload for an AreasByPostcodeResponse" do
      should "return code and areas attributes in a hash" do
        location = OpenStruct.new(:response => MockResponse.new(200, { "areas" => @areas }))
        response = MapitApi::AreasByPostcodeResponse.new(location)

        assert_equal 200, response.payload[:code]
        assert_equal 123, response.payload[:areas].first["id"]
        assert_equal "Westminster City Council", response.payload[:areas].first["name"]
        assert_equal 234, response.payload[:areas].last["id"]
        assert_equal "London", response.payload[:areas].last["name"]
      end
      should "return a 404 code and no areas if no location is found" do
        location = nil
        response = MapitApi::AreasByPostcodeResponse.new(location)

        assert_equal 404, response.payload[:code]
        assert_equal [], response.payload[:areas]
      end

    end
  end
end
