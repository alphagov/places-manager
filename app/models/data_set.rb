require "govspeak/html_validator"
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

  validates_presence_of :version

  # Mongoid has a 16M limit on document size.  Set this to
  # 15M to leave some headroom for storing the rest of the document.
  validates :csv_data, :length => {:maximum => 15.megabytes, :message => "CSV file is too big (max is 15MB)"}

  default_scope order_by([:version, :asc])
  before_validation :set_version, :on => :create
  after_save :schedule_csv_processing

  def places
    Place.where(service_slug: service.slug, data_set_version: version)
  end

  def places_near(location, distance = nil, limit = nil)
    Place.find_near(location, distance, limit, {service_slug: service.slug, data_set_version: version})
  end

  def duplicate
    duplicated_data_set = self.service.data_sets.create(:change_notes => "Created from Version #{self.version}")
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
    self.csv_data.blank? and self.processing_error.blank?
  end

  def data_file=(file)
    self.csv_data = file.read.force_encoding('UTF-8')

    # TODO: restructure this so that it runs as part of the model validations.
    raise HtmlValidationError unless Govspeak::HtmlValidator.new(self.csv_data).valid?

    # This instance variable is necessary becasue you can't schedule a delayed job until
    # the model has been persisted
    @need_csv_processing = true
  end

  def schedule_csv_processing
    if @need_csv_processing
      # This has to be scheduled on the service because the delayed_job mongoid driver
      # doesn't support running jobs on embedded documents.
      service.delay.process_csv_data(self.version)
      @need_csv_processing = false
    end
  end

  def process_csv_data
    if self.csv_data.present?
      CSV.parse(self.csv_data, headers: true) do |row|
        Place.create_from_hash(self, row)
      end
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

  def activate!
    return false unless self.processing_complete?
    service.active_data_set_version = self.version
    service.save
  end

  def new_action(user,type,comment)
    action = Action.new(:requester_id=>user.id,:request_type=>type,:comment=>comment)
    self.actions << action
    action
  end
end

class HtmlValidationError < StandardError; end
