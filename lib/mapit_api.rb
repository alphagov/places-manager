require "gds_api/exceptions"

module MapitApi
  class InvalidPostcodeError < StandardError; end
  class ValidPostcodeNoLocation < StandardError; end
  class InvalidLocationHierarchyType < ArgumentError; end

  def self.location_for_postcode(postcode)
    location_data = Imminence.mapit_api.location_for_postcode(postcode)
    raise ValidPostcodeNoLocation if location_data.lat.nil? || location_data.lon.nil?

    location_data
  rescue GdsApi::HTTPClientError
    raise InvalidPostcodeError
  end

  # The subset of Mapit area types that correspond to districts.
  #
  # See http://mapit.mysociety.org/#api-multiple_areas for details
  # of the various area types.
  DISTRICT_TYPES = %w(DIS LBO MTD UTA COI).freeze
  COUNTY_TYPES = %w(CTY LBO MTD UTA COI).freeze

  def self.district_snac_for_postcode(postcode)
    location_data = location_for_postcode(postcode)
    extract_snac_from_mapit_response(location_data, "district")
  end

  def self.extract_snac_from_mapit_response(location_data, location_hiearachy_type)
    area_types_to_check = area_types(location_hiearachy_type)
    found_area = location_data.areas.detect { |area| area_types_to_check.include?(area["type"]) }
    found_area["codes"]["ons"] if found_area
  end

  def self.area_types(location_hiearachy_type)
    case location_hiearachy_type
    when "district"
      DISTRICT_TYPES
    when "county"
      COUNTY_TYPES
    else
      raise InvalidLocationHierarchyType.new(location_hiearachy_type)
    end
  end
  private_class_method :area_types

  class AreasByTypeResponse
    def initialize(response)
      @response = response
    end

    def payload
      if @response
        {
          code: @response.code,
          areas: @response.to_hash.values,
        }
      else
        { code: 404, areas: [] }
      end
    end
  end

  class AreasByPostcodeResponse
    def initialize(location)
      @location = location
    end

    def payload
      # Invalid postcodes return a nil response
      if @location
        {
          code: @location.response.code,
          areas: @location.response.to_hash.fetch("areas", {}).values,
        }
      else
        { code: 404, areas: [] }
      end
    end
  end
end
