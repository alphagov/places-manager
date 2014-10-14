module MapitApi
  class InvalidPostcodeError < StandardError; end

  def self.location_for_postcode(postcode)
    location_data = Imminence.mapit_api.location_for_postcode(postcode)
    raise InvalidPostcodeError if location_data.nil?
    location_data
  end

  # The subset of Mapit area types that correspond to districts.
  #
  # See http://mapit.mysociety.org/#api-multiple_areas for details
  # of the various area types.
  DISTRICT_TYPES = %w(DIS LBO MTD UTA COI).freeze

  def self.district_snac_for_postcode(postcode)
    location_data = location_for_postcode(postcode)

    district = location_data.areas.detect {|area| DISTRICT_TYPES.include?(area.type) }
    district.codes['ons'] if district
  end

  class AreasByTypeResponse
    def initialize(response)
      @response = response
    end
    def payload
      {
        :code => @response.code,
        :areas => @response.to_hash.values
      }
    end
  end

  class RegionsResponse
    def initialize(response)
      @response = response
    end
    def payload
      {
        :code => @response.code,
        :areas => normalise_regions(@response.to_hash.values)
      }
    end

    private

    def normalise_regions(regions)
      eastern_index = regions.index { |r| r["name"] == "Eastern" }
      regions[eastern_index]["name"] = "East of England" if eastern_index

      regions.unshift({ "name" => "England", "country_name" => "England", "type" => "EUR" })
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
          :code => @location.response.code,
          :areas => @location.response.to_hash["areas"].values
        }
      else
        { :code => 404, :areas => [] }
      end
    end
  end
end
