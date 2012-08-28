require "govuk_content_models/html_validator"

class DataSet
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :service
  embeds_many :actions

  field :version, :type => Integer, :default => 1
  before_save :set_version, :on => :create

  def places
    Place.where(service_slug: service.slug, data_set_version: version)
  end

  def places_near(location, distance = nil, limit = nil)
    Place.find_near(location, distance, limit, {service_slug: service.slug, data_set_version: version})
  end

  def set_version
    other_data_sets = service.data_sets.to_a - [self]

    if self.version.blank? or (self.version == 1 and other_data_sets.length >= 1)
      self.version = other_data_sets.length + 1
    end
  end

  # This will run after 'set_version' because it is defined later
  # If these get swapped around, the places will be created without a data set
  # version, and all kinds of horribleness will ensue
  before_save :process_data_file
  def process_data_file
    if @data_file
      data = @data_file.read
      if HtmlValidator.new(data).valid?
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
