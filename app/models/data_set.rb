require "govspeak/html_validator"

class DataSet
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :service
  embeds_many :actions

  field :version,       type: Integer, :default => 1
  field :change_notes,  type: String

  validates_presence_of :version

  default_scope order_by([:version, :asc])
  before_validation :set_version, :on => :create

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
    other_data_sets = service.data_sets.to_a - [self]

    if self.version.blank? or (self.version == 1 and other_data_sets.length >= 1)
      highest_version = other_data_sets.map(&:version).max
      if highest_version
        self.version = highest_version + 1
      else
        self.version = 1
      end
    end
  end

  # This will run after 'set_version' because it is defined later
  # If these get swapped around, the places will be created without a data set
  # version, and all kinds of horribleness will ensue
  before_save :process_data_file
  def process_data_file
    if @data_file
      data = @data_file.read.force_encoding('UTF-8')
      if Govspeak::HtmlValidator.new(data).valid?
        CSV.parse(data, headers: true) do |row|
          Place.create_from_hash(self, row)
        end
      else
        raise HtmlValidationError
      end
    end
  end

  def data_file=(file)
    @data_file = file
  end

  def active?
    self.version == service.active_data_set_version
  end

  def latest_data_set?
    self.id.to_s == service.latest_data_set.id.to_s
  end

  def activate!
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
