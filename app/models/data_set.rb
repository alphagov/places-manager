require 'csv'

class DataSet
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :service
  embeds_many :actions

  field :version,       type: Integer
  field :change_notes,  type: String
  field :csv_data,      type: String
  field :processing_error, type: String
  field :state, type: String
  field :archiving_error, type: String

  validates_presence_of :version

  # Mongoid has a 16M limit on document size.  Set this to
  # 15M to leave some headroom for storing the rest of the document.
  validates :csv_data, length: { maximum: 15.megabytes, message: "CSV file is too big (max is 15MB)" }

  default_scope -> { order_by([:version, :asc]) }
  before_validation :set_version, on: :create
  after_save :schedule_csv_processing

  state_machine initial: :unarchived do
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
  #
  # Returns:
  #   an array of Place objects
  def places_near(location, distance = nil, limit = nil)
    query = places
    query = query.limit(limit) if limit
    query = query.geo_near([location.longitude, location.latitude])
    query = query.max_distance(distance.in(:degrees)) if distance
    query
  end

  def places_for_postcode(postcode, distance = nil, limit = nil)
    if service.location_match_type == 'local_authority'
      snac = MapitApi.district_snac_for_postcode(postcode)
      if snac
        places.where(snac: snac)
      else
        []
      end
    else
      location_data = MapitApi.location_for_postcode(postcode)
      location = Point.new(latitude: location_data.lat, longitude: location_data.lon)
      places_near(location, distance, limit)
    end
  end

  def duplicate
    duplicated_data_set = self.service.data_sets.create(change_notes: "Created from Version #{self.version}")
    self.places.each do |place|
      duplicated_place = place.dup
      duplicated_place.data_set_version = duplicated_data_set.version
      duplicated_place.save
    end

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
    self.csv_data = read_as_utf8(file)

    @need_csv_processing = true
  end

  def schedule_csv_processing
    if @need_csv_processing
      ProcessCsvDataWorker.perform_async(service.id.to_s, self.version)
      @need_csv_processing = false
    end
  end

  def process_csv_data
    if self.csv_data.present?
      places_data = []
      CSV.parse(self.csv_data, headers: true) do |row|
        places_data << Place.parameters_from_hash(self, row)
      end
      Place.create(places_data)
      self.csv_data = nil
      self.save!
    end
  rescue CSV::MalformedCSVError
    self.processing_error = "Could not process CSV file. Please check the format."
    self.csv_data = nil
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

private

  def read_as_utf8(file)
    string = file.read.force_encoding('utf-8')
    unless string.valid_encoding?
      # Try windows-1252 (which is a superset of iso-8859-1)
      string.force_encoding('windows-1252')
      # Any stream of bytes should be a vaild Windows-1252 string, so we use the presence of any
      # ASCII control chars (except for \r and \n) as a good heuristic to determine if this is
      # likely to be the correct charset
      if string.valid_encoding? && ! string.match(/[\x00-\x09\x0b\x0c\x0e-\x1f]/)
        return string.encode('utf-8')
      end

      raise InvalidCharacterEncodingError, "Unknown character encoding"
    end
    string
  end
end
