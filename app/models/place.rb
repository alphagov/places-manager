class CannotEditPlaceDetailsUnlessNewestInactiveDataset < ActiveModel::Validator
  def validate(record)
    if record.changes.except("location", "geocode_error").any?
      unless !record.data_set or record.can_edit?
        record.errors[:base] << ("Can only edit the most recent inactive dataset.")
      end
    end
  end
end

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

  scope :needs_geocoding, where(:location => nil, :geocode_error.exists => false)
  scope :with_geocoding_errors, where(:geocode_error.exists => true)
  scope :geocoded, where(:location.size => 2)
  default_scope order_by([:name,:asc])

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
  field :override_lat,   :type => Float 
  field :override_lng,   :type => Float
  field :geocode_error,  :type => String

  validates_presence_of :service_slug
  validates_presence_of :data_set_version
  validates_presence_of :source_address
  validates_presence_of :postcode
  validates_numericality_of :override_lat, :allow_blank => true
  validates_numericality_of :override_lng, :allow_blank => true
  validate :has_both_lat_lng_overrides
  validates_with CannotEditPlaceDetailsUnlessNewestInactiveDataset, :on => :update

  index [[:location, Mongo::GEO2D], [:service_slug, Mongo::ASCENDING], [:data_set_version, Mongo::ASCENDING]], background: true
  index [[:service_slug, Mongo::ASCENDING], [:data_set_version, Mongo::ASCENDING]]
  index :name, :background => true

  attr_accessor :dis
  before_validation :build_source_address
  before_validation :clear_location, :if => :postcode_changed?, :on => :update
  before_save :geocode

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
    if override_lat_lng?
      self.location = Point.new(latitude: override_lat, longitude: override_lng)
    end

    return unless location.blank?

    if postcode.blank?
      self.geocode_error = "Can't geocode without postcode"
    else
      result = Imminence.mapit_api.location_for_postcode(self.postcode)
      if result
        self.location = Point.new(
          latitude: result.lat,
          longitude: result.lon
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

  def can_edit?
    data_set.latest_data_set? and !data_set.active?
  end

  def build_source_address
    new_source_address = [address1, address2, town, postcode].compact.join(', ')

    if self.new_record? and self.source_address.blank?
      self.source_address = new_source_address
    end
  end

  private

  def clear_location
    self.location = nil
  end

  def override_lat_lng?
    override_lat.present? and override_lng.present?
  end

  def has_both_lat_lng_overrides
    unless override_lat_lng? or (override_lat.blank? and override_lng.blank?)
      errors.add(:override_lat, "latitude must be a valid coordinate") unless override_lat.present?
      errors.add(:override_lng, "longitude must be a valid coordinate") unless override_lng.present?
    end
  end

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
      phone: row['phone'],
      fax: row['fax'],
      text_phone: row['text_phone'],
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
