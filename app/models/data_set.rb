require "csv"

class DataSet < ApplicationRecord
  belongs_to :service

  validates :version, presence: true

  default_scope -> { order(version: :asc) }
  before_validation :set_version, on: :create
  validate :csv_data_is_valid
  after_save :schedule_csv_processing

  state_machine initial: :unarchived do
    event :duplicated do
      transition duplicating: :unarchived
    end

    event :archive do
      transition unarchived: :archiving
    end

    event :archived do
      transition archiving: :archived
    end
  end

  def places
    Place.where(service_slug: service.slug, data_set_version: version)
  end

  def number_of_places
    places.count
  end

  ##
  # Find all the places near a given location
  #
  # Arguments:
  #   location - a Point object representing the centre of the search area
  #   distance (optional) - a Distance object representing the maximum distance
  #   limit (optional) - a maximum number of results to return
  #   authority_code (optional) - array of GSS codes to scope the results to a local authority
  #
  # Returns:
  #   an array of Place objects
  def places_near(location, distance = nil, limit = nil, authority_code = nil)
    loc_string = "'SRID=4326;POINT(#{location.longitude} #{location.latitude})'::geometry"
    query = places
    query = query.where(gss: authority_code) if authority_code
    query = query.limit(limit) if limit
    query = query.where(Place.arel_table[:location].st_distance(location).lt(distance.in(:meters))) if distance
    query = query.reorder(Arel.sql("location <-> #{loc_string}, RANDOM()"))
    query.select(Arel.sql("places.*, ST_Distance(location, #{loc_string}) as distance"))
  end

  def places_for_postcode(postcode, distance = nil, limit = nil, local_authority_slug = nil)
    location_data = GdsApi.locations_api.coordinates_for_postcode(postcode)
    raise GdsApi::HTTPNotFound, "Postcode exists, but has no location info" unless location_data

    location = RGeo::Geographic.spherical_factory.point(location_data["longitude"], location_data["latitude"])
    return places_near(location, distance, limit) if service.location_match_type == "nearest"

    authority_code = if local_authority_slug
                       authority_code_for_local_authority_slug(local_authority_slug)
                     else
                       appropriate_authority_code_for_postcode(postcode)
                     end
    return [] unless authority_code

    places_near(location, distance, limit, authority_code)
  end

  def authority_code_for_local_authority_slug(local_authority_slug)
    local_authorities_response = GdsApi.local_links_manager.local_authority(local_authority_slug)

    local_authority = local_authorities_response.to_hash["local_authorities"].find do |la|
      [service.local_authority_hierarchy_match_type, "unitary"].include?(la["tier"])
    end

    local_authority["gss"]
  end

  def appropriate_authority_for_local_custodian_code(local_custodian_code)
    local_authorities_response = GdsApi.local_links_manager.local_authority_by_custodian_code(local_custodian_code)
    local_authorities_response.to_hash["local_authorities"].find do |la|
      [service.local_authority_hierarchy_match_type, "unitary"].include?(la["tier"])
    end
  end

  def appropriate_authority_code_for_postcode(postcode)
    local_custodian_codes = GdsApi.locations_api.local_custodian_code_for_postcode(postcode)
    return nil if local_custodian_codes.compact.empty?

    if local_custodian_codes.count > 1
      postcode_response = GdsApi.locations_api.results_for_postcode(postcode)
      authorities = local_custodian_codes.index_with { |lcc| appropriate_authority_for_local_custodian_code(lcc) }

      response = postcode_response["results"].map do |a|
        {
          address: a["address"],
          local_authority_slug: authorities[a["local_custodian_code"]]["slug"],
        }
      end

      raise(AmbiguousPostcodeError, response)
    end

    authority_hash = appropriate_authority_for_local_custodian_code(local_custodian_codes.first) # there should be 0-1, return first or nil
    authority_hash["gss"]
  rescue GdsApi::HTTPNotFound
    nil
  end

  def duplicating?
    state == "duplicating"
  end

  def duplicate
    duplicated_data_set = service.data_sets.create!(
      change_notes: "Created from Version #{version}",
      state: "duplicating",
    )
    places.each do |place|
      duplicated_place = place.dup
      duplicated_place.data_set_version = duplicated_data_set.version
      duplicated_place.save!
    end
    duplicated_data_set.duplicated
    duplicated_data_set
  end

  def set_version
    if version.blank?
      other_data_sets = service.data_sets.to_a - [self]
      highest_version = other_data_sets.map(&:version).max
      self.version = if highest_version
                       highest_version + 1
                     else
                       1
                     end
    end
  end

  def processing_complete?
    csv_data.blank? && processing_error.blank?
  end

  def data_file=(file)
    if file.nil?
      @csv_data = nil
      @need_csv_processing = false
    else
      @csv_data = CsvData.new(data_file: file)
      @need_csv_processing = true
    end
  end

  def schedule_csv_processing
    if @need_csv_processing
      @csv_data.save!
      ProcessCsvDataWorker.perform_async(service.id.to_s, version)
      @need_csv_processing = false
    end
  end

  def csv_data
    @csv_data ||= CsvData.find_by(service_slug: service.slug, data_set_version: version)
  end

  def csv_data_is_valid
    return if @csv_data.nil? || @csv_data.destroyed?

    @csv_data.service_slug = service.slug
    @csv_data.data_set_version = version
    unless @csv_data.valid?
      @csv_data.errors[:data].each do |message|
        errors.add(:data_file, message)
      end
    end
  end

  def reset_csv_data
    @csv_data.destroy!
    @csv_data = nil
  end

  def process_csv_data
    if csv_data.present?
      places_data = []
      CSV.parse(csv_data.data, headers: true) do |row|
        places_data << Place.parameters_from_hash(self, row)
      end
      Place.create!(places_data)
      reset_csv_data
      save!
    else
      self.processing_error = "CSV file empty. Try again or contact support."
    end
  rescue CSV::MalformedCSVError => e
    Rails.logger.error("Could not process CSV file. Please check the format: #{e}")
    self.processing_error = "Could not process CSV file. Please check the format."
    reset_csv_data
    save!
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("Database error occurred. Please try re-importing: #{e}")
    self.processing_error = "Database error occurred. Please try re-importing."
    reset_csv_data
    save!
  end

  def active?
    version == service.active_data_set_version
  end

  def latest_data_set?
    id.to_s == service.latest_data_set.id.to_s
  end

  def can_be_made_active?
    !active? &&
      processing_complete? &&
      processing_error.blank? &&
      number_of_places.positive?
  end

  def activate
    return false unless processing_complete?

    service.active_data_set_version = version
    service.save!
  end

  def archive_places
    places.each do |place|
      PlaceArchive.create!(place.attributes.except("id"))
    end
    places.delete_all
    archived!
  rescue StandardError => e
    update!(archiving_error: "Failed to archive place information: '#{e.message}'")
  end

  def delete_records
    PlaceArchive.where(service_slug: service.slug, data_set_version: version).delete_all
    delete
  end

  def has_places_with_missing_gss_codes?
    service.uses_local_authority_lookup? && places.missing_gss_codes.count > 0 # rubocop:disable Style/NumericPredicate
  end
end
