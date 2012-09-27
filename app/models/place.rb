class Place
  include Mongoid::Document

  class PointField
    # Declare a field of this type to have it deserialise to a Point

    include Mongoid::Fields::Serializable

    def deserialize(value)
      return nil unless value

      if value.is_a? Array
        legacy_deserialize value
      else
        Point.new(longitude: value["longitude"], latitude: value["latitude"])
      end
    end

    def serialize(point)
      return nil unless point

      {"longitude" => point.longitude, "latitude" => point.latitude}
    end

  private
    def legacy_deserialize(value)
        # Legacy [lat, lng] data format
        # An empty array (or a single co-ordinate, which shouldn't happen) is
        # an invalid value and deserializes to nil
        case value.size
        when 2
          Point.new(latitude: value[0], longitude: value[1])
        when 0
          nil
        else
          Rails.logger.error "Invalid location #{value.inspect}"
          nil
        end
    end
  end

  scope :needs_geocoding, where(:location.size => 0, :geocode_error.exists => false)
  scope :with_geocoding_errors, where(:geocode_error.exists => true)
  scope :geocoded, where(:location.size => 2)

  field :service_slug,   :type => String
  field :data_set_version, :type => Integer

  field :name,           :type => String
  field :source_address, :type => String
  field :address1,       :type => String
  field :address2,       :type => String
  field :town,           :type => String
  field :postcode,       :type => String
  field :access_notes,   :type => String
  field :general_notes,  :type => String
  field :url,            :type => String
  field :email,          :type => String
  field :phone,          :type => String
  field :fax,            :type => String
  field :text_phone,     :type => String
  field :location,       :type => PointField
  field :geocode_error,  :type => String

  validates_presence_of :service_slug
  validates_presence_of :data_set_version
  validates_presence_of :source_address
  validates_presence_of :postcode

  index [[:location, Mongo::GEO2D], [:service_slug, Mongo::ASCENDING], [:data_set_version, Mongo::ASCENDING]], background: true
  index [[:service_slug, Mongo::ASCENDING], [:data_set_version, Mongo::ASCENDING]]

  attr_accessor :dis
  before_save :reconcile_location

  def data_set
    service = Service.where(slug: service_slug).first
    if service
      service.data_sets.where(version: data_set_version).first
    end
  end

  ##
  # Find all the points near a given location
  #
  # This returns Place objects with a 'dis' attribute representing the
  # mongodb derived distance of that place from the origin of the search.
  #
  # That doesn't feel quite right and this API is subject to change, perhaps
  # to return an array of arrays, eg. [[distance, Place], [distance2, Place2]]?
  #
  # Arguments:
  #   location - a Point object representing the centre of the search area
  #   distance (optional) - a Distance object representing the maximum distance
  #       - only miles are currently supported
  #   limit (optional) - a maximum number of results to return
  #
  # Returns:
  #   an array of Place objects with a 'dis' attribute
  def self.find_near(location, distance = nil, limit = nil, extra_query = {})

    opts = {
      "geoNear" => "places",
      "near" => [location.longitude, location.latitude],
      "spherical" => true,
      "query" => extra_query
    }

    if distance
      opts["maxDistance"] = distance.in(:radians)
    end

    if limit
      opts["num"] = limit.to_i
    end

    response = Mongoid.master.command(opts)
    response["results"].collect do |result|
      Mongoid::Factory.from_db(self, result["obj"]).tap do |doc|
        doc.dis = Distance.new(result["dis"], :radians)
      end
    end
  end

  def self.create_from_hash(data_set, row, options={})
    place = new(parameters_from_hash(data_set, row))
    place.save(options)
    place
  end

  def self.create_from_hash!(data_set, row, options={})
    place = new(parameters_from_hash(data_set, row))
    place.save!(options)
    place
  end

  def geocode
    if postcode.blank?
      self.geocode_error = "Can't geocode without postcode"
    elsif location.nil? or location.empty?
      lookup = Geogov.lat_lon_from_postcode(self.postcode)
      if lookup
        self.location = Point.new(
          latitude: lookup.values[0],
          longitude: lookup.values[1]
        )
      else
        self.geocode_error = "#{self.postcode} not found for #{self.full_address}"
      end
    end
  rescue => e
    error = "Error geocoding place #{self.postcode} : #{e.message}"
    Rails.logger.warn error
    self.geocode_error = error
  rescue Encoding::CompatibilityError
    error = "Encoding error in place #{self.id}"
    Rails.logger.warn error
    self.geocode_error = error
  end

  def geocode!
    geocode
    save!
  end

  def address
    [address1, address2].select(&:present?).map(&:strip).join(', ')
  end

  def full_address
    [address, town, postcode, 'UK'].select { |i| i.present? }.map(&:strip).join(', ')
  end

  def to_s
    [name, full_address, url].select(&:present?).join(', ')
  end

  def lat
    location.nil? ? nil : location.latitude
  end

  def lng
    location.nil? ? nil : location.longitude
  end

  def lat=(value)
    if location
      location = Point.new(longitude: location.longitude, latitude: value)
    else
      @temp_lat = value
    end
  end

  def lng=(value)
    if location
      location = Point.new(longitude: value, latitude: location.latitude)
    else
      @temp_lng = value
    end
  end

  def reconcile_location
    # This slight hack is needed to get around code setting latitude and
    # longitude separately on a new object. Because we can't construct a Point
    # field until we have both, we store them in temporary variables and build
    # the point on save
    if location.nil? && @temp_lat && @temp_lng
      self.location = Point.new(longitude: @temp_lng, latitude: @temp_lat)
    end
  end

  private
  def self.parameters_from_hash(data_set, row)
    # Create parameters suitable for passing to build, create, etc.
    base_parameters = {
      service_slug: data_set.service.slug,
      data_set_version: data_set.version,
      name: row['name'],
      address1: row['address1'],
      address2: row['address2'],
      town: row['town'],
      postcode: row['postcode'],
      access_notes: row['access_notes'],
      general_notes: row['general_notes'],
      url: row['url'],
      email: row['email'],
      source_address: row['source_address'] || "#{row['address1']} #{row['address2']} #{row['town']} #{row['postcode']}"
    }
    location_parameters = if row['location']
      {location: PointField.new.deserialize(row['location'])}
    elsif row['lng'] && row['lat']
      {location: Point.new(longitude: row['lng'], latitude: row['lat'])}
    else
      {}
    end
    return base_parameters.merge(location_parameters)
  end
end
