class Service < ApplicationRecord
  LOCATION_MATCH_TYPES = %w[nearest local_authority].freeze
  LOCAL_AUTHORITY_DISTRICT_MATCH = "district".freeze
  LOCAL_AUTHORITY_COUNTY_MATCH = "county".freeze
  LOCAL_AUTHORITY_HIERARCHY_MATCH_TYPES = [LOCAL_AUTHORITY_DISTRICT_MATCH, LOCAL_AUTHORITY_COUNTY_MATCH].freeze

  has_many :data_sets do
    def current
      where.not(state: "archived")
    end
  end

  validates :name, presence: true

  # underscore allowed because one of the existing services uses them in its slug.
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_-]*\z/ }
  validates :location_match_type, inclusion: { in: LOCATION_MATCH_TYPES }
  validates :local_authority_hierarchy_match_type, inclusion: { in: LOCAL_AUTHORITY_HIERARCHY_MATCH_TYPES }

  before_validation :create_first_data_set, on: :create
  after_save :schedule_csv_processing
  after_validation :promote_data_file_errors

  def reconcile_place_locations
    data_sets.first.places.map(&:reconcile_location)
  end

  def data_file=(file)
    @need_csv_processing = data_sets.build(data_file: file)
  end

  def schedule_csv_processing
    if @need_csv_processing
      @need_csv_processing.schedule_csv_processing
      @need_csv_processing = nil
    end
  end

  def promote_data_file_errors
    if @need_csv_processing
      @need_csv_processing.errors[:data_file].each do |message|
        errors.add(:data_file, message)
      end
    end
  end

  def process_csv_data(data_set_version)
    data_sets.find_by(version: data_set_version).process_csv_data
  end

  def active_data_set
    @active_data_set ||= data_sets.detect { |ds| ds.version == active_data_set_version }
  end

  def latest_data_set
    data_sets.order(version: :desc).first
  end

  def create_first_data_set
    data_sets.build unless data_sets.any?
  end

  def schedule_archive_places
    obsolete_data_sets.each { |ds| ds.archive! if ds.places.count.positive? }
    ArchivePlacesWorker.perform_async(id.to_s)
  end

  def archive_places
    obsolete_data_sets.each { |ds| ds.archive_places if ds.places.count.positive? }
  end

  # returns all data sets up to but not including the data set before the active set
  def obsolete_data_sets
    data_sets.take_while { |ds| ds != active_data_set }.slice(0...-1)
  end

  def uses_local_authority_lookup?
    location_match_type == "local_authority"
  end
end
