API_KEY = "xx"
API_SECRET = "xx"

require "oauth2"

require "gds_api/exceptions"

module MapitApi
  class InvalidPostcodeError < StandardError; end
  class ValidPostcodeNoLocation < StandardError; end
  class InvalidLocationHierarchyType < ArgumentError; end

  def self.location_for_postcode(postcode)
    client = OAuth2::Client.new(API_KEY, API_SECRET, site: "https://api.os.uk", token_url: "/oauth2/token/v1")

    token = client.client_credentials.get_token

    response = token.get("/search/places/v1/postcode", params: {postcode: postcode, dataset: "DPA"}) # DPA = Delivery Point Addresses, i.e. postal addresses

    JSON.parse(response.body)["results"]
  end

  # The subset of Mapit area types that correspond to districts.
  #
  # See http://mapit.mysociety.org/#api-multiple_areas for details
  # of the various area types.
  DISTRICT_TYPES = %w[DIS LBO MTD UTA COI].freeze
  COUNTY_TYPES = %w[CTY LBO MTD UTA COI].freeze

  def self.district_snac_for_postcode(postcode)
    location_data = location_for_postcode(postcode)
    extract_snac_from_mapit_response(location_data, "district")
  end

  def self.extract_snac_from_mapit_response(location_data, location_hiearachy_type)
    address = location_data.first

    ## TODO: Can we get the GSS code without needing to make another 2 queries??
    coordinates = [address.dig("DPA", "X_COORDINATE"), address.dig("DPA", "Y_COORDINATE")].join(",")

    response = token.get("/search/names/v1/nearest", params: {point: coordinates})

    utla_url = JSON.parse(response.body).dig("results", 0, "GAZETTEER_ENTRY", "COUNTY_UNITARY_URI")
    ltla_url = JSON.parse(response.body).dig("results", 0, "GAZETTEER_ENTRY", "DISTRICT_BOROUGH_URI")

    ## We need to return the lowest level of local authority, i.e. the LTLA, unless it is a Unitary Authority, then the UTLA
    if location_hiearachy_type == "district"
      gss_code_from_authority_url(ltla_url)  ## TODO: need to get the SNAC code
    elsif location_hiearachy_type == "county"
      gss_code_from_authority_url(utla_url)  ## TODO: need to get the SNAC code
    else
      raise InvalidLocationHierarchyType, location_hiearachy_type
    end
  end

  def self.gss_code_from_authority_url(url)
    uri = URI.parse("#{url.gsub('id', 'doc')}.json") # The gsub is a hack as Net::HTTP doesn't follow redirects
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body).dig(url, "http://data.ordnancesurvey.co.uk/ontology/admingeo/gssCode", 0, "value")
  end
end
