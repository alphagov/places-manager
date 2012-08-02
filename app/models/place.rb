class Place
  include Mongoid::Document
  include GeoTools

  scope :needs_geocoding, where(:location.size => 0, :geocode_error.exists => false)
  scope :with_geocoding_errors, where(:geocode_error.exists => true)
  scope :geocoded, where(:location.size => 2)

  scope :near_within_miles, proc { |lat, lng, distance|
    # Distances are in the same units as the co-ordinates so we need
    # to do some maths to convert our values.
    where(:location => {"$near" => [lat, lng], "$maxDistance" => distance.fdiv(111.12)})
  }

  field :service_slug,   :type => String
  field :data_set_version, :type => Integer

  field :name,           :type => String
  field :source_address, :type => String
  field :address1,        :type => String
  field :address2,        :type => String
  field :town,           :type => String
  field :postcode,       :type => String
  field :access_notes,   :type => String
  field :general_notes,  :type => String
  field :url,            :type => String
  field :phone,          :type => String
  field :fax,            :type => String
  field :text_phone,     :type => String
  field :location,       :type => Array, :geo => true, :default => []
  field :geocode_error,  :type => String

  validates_presence_of :service_slug
  validates_presence_of :data_set_version
  validates_presence_of :source_address
  validates_presence_of :postcode

  index [[:location, Mongo::GEO2D], [:service_slug, Mongo::ASCENDING], [:data_set_version, Mongo::ASCENDING]], background: true

  attr_accessor :distance

  def geocode
    if postcode.blank?
      self.geocode_error = "Can't geocode without postcode"
    elsif location.nil? or location.empty?
      lookup = Geogov.lat_lon_from_postcode(self.postcode)
      if lookup
        self.location = lookup.values
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

  def distance_from(lat, lng)
    from = {'lat' => location[0], 'lng' => location[1]}
    to = {'lat' => lat, 'lng' => lng}
    distance_between(from, to)
  end

  def to_s
    [name, full_address, url].select(&:present?).join(', ')
  end

  def lat
    location.nil? ? nil : location[0]
  end

  def lng
    location.nil? ? nil : location[1]
  end

  def lat=(value)
    @temp_lat = value.to_f
  end

  def lng=(value)
    @temp_lng = value.to_f
  end

  def reconcile_location
    if location.empty? && @temp_lat && @temp_lng
      self.location = [@temp_lat, @temp_lng]
    end
  end
end
