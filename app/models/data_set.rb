require "csv"

class DataSet
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :service
  embeds_many :actions

  field :version,       type: Integer
  field :change_notes,  type: String
  field :processing_error, type: String
  field :state, type: String
  field :archiving_error, type: String

  validates_presence_of :version

  default_scope -> { order_by(%i[version asc]) }
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

  ##
  # Find all the places near a given location
  #
  # Arguments:
  #   location - a Point object representing the centre of the search area
  #   distance (optional) - a Distance object representing the maximum distance
  #   limit (optional) - a maximum number of results to return
  #   snac (optional) - a SNAC code to scope the results to a local authority
  #
  # Returns:
  #   an array of Place objects
  def places_near(location, distance = nil, limit = nil, snac = nil)
    query = places
    query = query.where(snac: snac) if snac
    query = query.limit(limit) if limit
    query = query.geo_near([location.longitude, location.latitude])
    query = query.max_distance(distance.in(:degrees)) if distance
    query
  end

  def places_for_postcode(postcode, distance = nil, limit = nil)
    location_data = MapitApi.location_for_postcode(postcode)
    location = Point.new(latitude: location_data.lat, longitude: location_data.lon)
    if service.location_match_type == "local_authority"
      snac = MapitApi.extract_snac_from_mapit_response(location_data, service.local_authority_hierarchy_match_type)
      if snac
        places_near(location, distance, limit, snac)
      else
        []
      end
    else
      places_near(location, distance, limit)
    end
  end

  def duplicating?
    self.state == "duplicating"
  end

  def duplicate
    duplicated_data_set = self.service.data_sets.create(
      change_notes: "Created from Version #{self.version}",
      state: "duplicating",
    )
    self.places.each do |place|
      duplicated_place = place.dup
      duplicated_place.data_set_version = duplicated_data_set.version
      duplicated_place.save
    end
    duplicated_data_set.duplicated
    duplicated_data_set
  end

  def set_version
    if self.version.blank?
      other_data_sets = service.data_sets.to_a - [self]
      highest_version = other_data_sets.map(&:version).max
      if highest_version
        self.version = highest_version + 1
      else
        self.version = 1
      end
    end
  end

  def processing_complete?
    self.csv_data.blank? && self.processing_error.blank?
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
      ProcessCsvDataWorker.perform_async(service.id.to_s, self.version)
      @need_csv_processing = false
    end
  end

  def csv_data
    @csv_data ||= CsvData.where(service_slug: service.slug, data_set_version: self.version).first
  end

  def csv_data_is_valid
    return if @csv_data.nil? || @csv_data.destroyed?
    @csv_data.service_slug = service.slug
    @csv_data.data_set_version = self.version
    unless @csv_data.valid?
      @csv_data.errors[:data].each do |message|
        errors.add(:data_file, message)
      end
    end
  end

  def reset_csv_data
    @csv_data.destroy
    @csv_data = nil
  end

  def process_csv_data
    if csv_data.present?
      places_data = []
      CSV.parse(csv_data.data, headers: true) do |row|
        places_data << Place.parameters_from_hash(self, row)
      end
      Place.create(places_data)
      reset_csv_data
      self.save!
    end
  rescue CSV::MalformedCSVError
    self.processing_error = "Could not process CSV file. Please check the format."
    reset_csv_data
    self.save!
  end

  def active?
    self.version == service.active_data_set_version
  end

  def latest_data_set?
    self.id.to_s == service.latest_data_set.id.to_s
  end

  def activate
    return false unless self.processing_complete?
    service.active_data_set_version = self.version
    service.save
  end

  def archive_places
    begin
      places.each do |place|
        PlaceArchive.create!(place.attributes)
      end
      places.delete_all
      self.archived
    rescue => e
      self.set(archiving_error: "Failed to archive place information: '#{e.message}'")
    end
  end

  def new_action(user, type, comment)
    action = Action.new(requester_id: user.id, request_type: type, comment: comment)
    self.actions << action
    action
  end

  def has_places_with_missing_snacs?
    service.uses_local_authority_lookup? && places.missing_snacs.count > 0
  end

private

  def read_as_utf8(file)
    string = file.read.force_encoding("utf-8")
    unless string.valid_encoding?
      # Try windows-1252 (which is a superset of iso-8859-1)
      string.force_encoding("windows-1252")
      # Any stream of bytes should be a vaild Windows-1252 string, so we use the presence of any
      # ASCII control chars (except for \r and \n) as a good heuristic to determine if this is
      # likely to be the correct charset
      if string.valid_encoding? && ! string.match(/[\x00-\x09\x0b\x0c\x0e-\x1f]/)
        return string.encode("utf-8")
      end

      raise InvalidCharacterEncodingError, "Unknown character encoding"
    end
    string
  end
end
