require "gds_api/exceptions"

class CannotEditPlaceDetailsUnlessNewestInactiveDataset < ActiveModel::Validator
  def validate(record)
    if record.changes.except("location", "geocode_error").any? && !(!record.data_set || record.can_edit?)
      record.errors.add(:base, "Can only edit the most recent inactive dataset.")
    end
  end
end

class Place < ApplicationRecord
  # Match documents with either no geocode error or a null value. Changed so
  # that anything without a location (or with a null location) is either
  # matched by `needs_geocoding` or `with_geocoding_errors`.
  scope :needs_geocoding, -> { where(location: nil, geocode_error: nil) }

  scope :with_geocoding_errors, -> { where.not(geocode_error: nil) }
  scope :geocoded, -> { where(:location.with_size => 2) }
  default_scope -> { order(name: :asc) }

  scope :missing_gss_codes, -> { where(gss: nil) }

  validates :service_slug, presence: true
  validates :data_set_version, presence: true
  validates :source_address, presence: true
  validates :postcode, presence: true
  validates :override_lat, numericality: { allow_blank: true }
  validates :override_lng, numericality: { allow_blank: true }
  validate :has_both_lat_lng_overrides
  validates_with CannotEditPlaceDetailsUnlessNewestInactiveDataset, on: :update

  before_validation :build_source_address
  before_validation :clear_location, if: :postcode_changed?, on: :update
  before_save :geocode

  def data_set
    service = Service.find_by(slug: service_slug)
    service.data_sets.find_by(version: data_set_version) if service
  end

  # When the place is created from a PostGIS distance search, it'll have an
  # additional 'distance' attribute in meters from the search point. Convert
  # to a Distance object so that we can easily convert it to other units.
  def dis
    if attributes["distance"]
      @dis ||= Distance.new(attributes["distance"], :meters)
    end
  end

  def geocode
    if override_lat_lng?
      self.location = "POINT (#{override_lng} #{override_lat})"
    end

    return if location.present?

    if postcode.blank?
      self.geocode_error = "Can't geocode without postcode"
    else
      result = GdsApi.locations_api.coordinates_for_postcode(postcode)
      self.location = "POINT (#{result['longitude']} #{result['latitude']})"
      self.geocode_error = nil
    end
  rescue GdsApi::HTTPNotFound
    self.geocode_error = "#{postcode} not found for #{full_address}"
  rescue Encoding::CompatibilityError
    error = "Encoding error in place #{id}"
    Rails.logger.warn error
    self.geocode_error = error
  rescue StandardError => e
    error = "Error geocoding place #{postcode} : #{e.message}"
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

    if new_record? && source_address.blank?
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
      gss: row["gss"],
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

  def api_safe_hash
    serializable_hash(except: :id).merge("location" => location_to_hash)
  end

  def location_to_hash
    return nil if location.nil?

    { latitude: location.latitude, longitude: location.longitude }
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
