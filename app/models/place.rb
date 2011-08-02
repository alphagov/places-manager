class Place
  include Mongoid::Document

  embedded_in :data_set

  field :name,          :type => String
  field :address,       :type => String
  field :town,          :type => String
  field :postcode,      :type => String
  field :access_notes,  :type => String
  field :general_notes, :type => String
  field :url,           :type => String
  field :location,      :type => Array, :geo => true, :lat => :latitude, :lng => :longitude

  index [[ :location, Mongo::GEO2D ]], :min => -180, :max => 180
  before_save :geocode!
  
  attr_accessor :distance
  
  def geocode!
    if location.nil? or location.empty?
      require 'graticule'
      geocoder = Graticule.service(:google).new(GOOGLE_API_KEY)
      this_location = geocoder.locate(full_address)
      self.location = [this_location.latitude, this_location.longitude]
    end
  rescue => e
    Rails.logger.warn "Error geocoding place #{self.inspect} : #{e.message}"
  end
  
  def full_address
    [address, town, postcode, 'UK'].select { |i| i.present? }.join(', ')
  end
  
  EARTH_RADIUS_IN_MILES = 3963.19
  MILES_PER_LATITUDE_DEGREE = 69.1
  LATITUDE_DEGREES = EARTH_RADIUS_IN_MILES / MILES_PER_LATITUDE_DEGREE 
  PI_DIV_RAD = 0.0174
  
  # Presuming we're working in miles. Stolen from geokit
  def distance_between(from, to, options={})
    return 0.0 if from == to # fixes a "zero-distance" bug
    formula = :flat
    case formula
      when :sphere
        begin
          EARTH_RADIUS_IN_MILES * 
              Math.acos( Math.sin(deg2rad(from['lat'])) * Math.sin(deg2rad(to['lat'])) + 
              Math.cos(deg2rad(from['lat'])) * Math.cos(deg2rad(to['lat'])) * 
              Math.cos(deg2rad(to['lng']) - deg2rad(from['lng'])))
        rescue Errno::EDOM
          0.0
        end
      when :flat
        Math.sqrt(
          (
            MILES_PER_LATITUDE_DEGREE*(from['lat']-to['lat'])
          )**2 + 
          (
            units_per_longitude_degree(from['lat']) * (from['lng']-to['lng'])
          )**2
        )
    end
  end

  def deg2rad(degrees)
    degrees.to_f / 180.0 * Math::PI
  end

  def units_per_longitude_degree(lat)
    (LATITUDE_DEGREES * Math.cos(lat * PI_DIV_RAD)).abs
  end

  def distance_from(lat, lng)
    from = {'lat' => location[0], 'lng' => location[1]}
    to = {'lat' => lat, 'lng' => lng}
    @distance ||= distance_between(from, to)
  end
end
