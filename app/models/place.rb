require "gds_api/exceptions"

class CannotEditPlaceDetailsUnlessNewestInactiveDataset < ActiveModel::Validator
  def validate(record)
    if record.changes.except("location", "geocode_error").any?
      unless !record.data_set || record.can_edit?
        record.errors[:base] << "Can only edit the most recent inactive dataset."
      end
    end
  end
end

class Place
  include Mongoid::Document

  # Match documents with either no geocode error or a null value. Changed so
  # that anything without a location (or with a null location) is either
  # matched by `needs_geocoding` or `with_geocoding_errors`.
  scope :needs_geocoding, -> { where(location: nil, geocode_error: nil) }

  # We use "not null" here instead of "exists", because it works with the index
  scope :with_geocoding_errors, -> { where(:geocode_error.ne => nil) }
  scope :geocoded, -> { where(:location.with_size => 2) }
  default_scope -> { order_by(%i[name asc]) }

  scope :missing_snacs, -> { where(snac: nil) }

  field :service_slug, type: String
  field :data_set_version, type: Integer

  field :name,           type: String
  field :source_address, type: String
  field :address1,       type: String
  field :address2,       type: String
  field :town,           type: String
  field :postcode,       type: String
  field :access_notes,   type: String
  field :general_notes,  type: String
  field :url,            type: String
  field :email,          type: String
  field :phone,          type: String
  field :fax,            type: String
  field :text_phone,     type: String
  field :location,       type: Point
  field :override_lat,   type: Float
  field :override_lng,   type: Float
  field :geocode_error,  type: String
  field :snac,           type: String

  validates_presence_of :service_slug
  validates_presence_of :data_set_version
  validates_presence_of :source_address
  validates_presence_of :postcode
  validates_numericality_of :override_lat, allow_blank: true
  validates_numericality_of :override_lng, allow_blank: true
  validate :has_both_lat_lng_overrides
  validates_with CannotEditPlaceDetailsUnlessNewestInactiveDataset, on: :update

  index({ location: "2d", service_slug: 1, data_set_version: 1 }, background: true)
  index(service_slug: 1, data_set_version: 1)

  # Index to speed up the `needs_geocoding` and `with_geocoding_errors` scopes
  index(
    service_slug: 1,
    data_set_version: 1,
    geocode_error: 1,
    location: 1,
  )

  index({ name: 1 }, background: true)

  before_validation :build_source_address
  before_validation :clear_location, if: :postcode_changed?, on: :update
  before_save :geocode

  def data_set
    service = Service.find_by(slug: service_slug)
    service.data_sets.find_by(version: data_set_version) if service
  end

  # Convert mongoid's geo_near_distance attribute to a Distance object
  # so that we can easily convert it to other units.
  def dis
    if attributes["geo_near_distance"]
      @dis ||= Distance.new(attributes["geo_near_distance"], :degrees)
    end
  end

  def self.create_from_hash(data_set, row, options = {})
    place = new(parameters_from_hash(data_set, row))
    place.save(options)
    place
  end

  def self.create_from_hash!(data_set, row, options = {})
    place = new(parameters_from_hash(data_set, row))
    place.save!(options)
    place
  end

  def geocode
    if override_lat_lng?
      self.location = Point.new(latitude: override_lat, longitude: override_lng)
    end

    return if location.present?

    if postcode.blank?
      self.geocode_error = "Can't geocode without postcode"
    else
      result = Imminence.mapit_api.location_for_postcode(self.postcode)
      self.location = Point.new(
        latitude: result.lat,
        longitude: result.lon,
      )
    end
  rescue GdsApi::HTTPClientError
    self.geocode_error = "#{self.postcode} not found for #{self.full_address}"
  rescue Encoding::CompatibilityError
    error = "Encoding error in place #{self.id}"
    Rails.logger.warn error
    self.geocode_error = error
  rescue StandardError => e
    error = "Error geocoding place #{self.postcode} : #{e.message}"
    Rails.logger.warn error
    self.geocode_error = error
  end

  def geocode!
    geocode
    save!
  end

  def address
    [address1, address2].select(&:present?).map(&:strip).join(", ")
  end

  def full_address
    [address, town, postcode, "UK"].select(&:present?).map(&:strip).join(", ")
  end

  def to_s
    [name, full_address, url].select(&:present?).join(", ")
  end

  def lat
    location.nil? ? nil : location.latitude
  end

  def lng
    location.nil? ? nil : location.longitude
  end

  def can_edit?
    data_set.latest_data_set? && !data_set.active?
  end

  def build_source_address
    new_source_address = [address1, address2, town, postcode].compact.join(", ")

    if self.new_record? && self.source_address.blank?
      self.source_address = new_source_address
    end
  end

  def self.parameters_from_hash(data_set, row)
    # Create parameters suitable for passing to build, create, etc.
    base_parameters = {
      service_slug: data_set.service.slug,
      data_set_version: data_set.version,
      name: row["name"],
      address1: row["address1"],
      address2: row["address2"],
      town: row["town"],
      postcode: row["postcode"],
      access_notes: row["access_notes"],
      general_notes: row["general_notes"],
      url: row["url"],
      email: row["email"],
      phone: row["phone"],
      fax: row["fax"],
      text_phone: row["text_phone"],
      source_address: row["source_address"] || "#{row['address1']} #{row['address2']} #{row['town']} #{row['postcode']}",
      snac: row["snac"],
    }
    location_parameters = if row["lng"] && row["lat"]
                            { override_lng: row["lng"], override_lat: row["lat"] }
                          else
                            {}
                          end
    base_parameters.merge(location_parameters)
  end

  def override_lat_lng?
    override_lat.present? && override_lng.present?
  end

private

  def clear_location
    self.location = nil
  end

  def has_both_lat_lng_overrides
    unless override_lat_lng? || (override_lat.blank? && override_lng.blank?)
      errors.add(:override_lat, "latitude must be a valid coordinate") if override_lat.blank?
      errors.add(:override_lng, "longitude must be a valid coordinate") if override_lng.blank?
    end
  end
end
