class Service
  include Mongoid::Document

  field :name,                    :type => String
  field :slug,                    :type => String
  field :active_data_set_version, :type => Integer, :default => 1
  field :source_of_data,          :type => String

  embeds_many :data_sets

  index :slug, :unique => true

  validates_presence_of :name

  # underscore allowed because one of the existing services uses them in its slug.
  validates :slug, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9_-]*\z/ }

  after_initialize :create_first_data_set
  after_save :process_data_file

  def process_data_file
    latest_data_set.process_data_file
  end

  def reconcile_place_locations
    data_sets.first.places.map(&:reconcile_location)
  end

  def data_file=(file)
    ds = self.data_sets.build
    ds.data_file = file
  end

  def active_data_set
    @active_data_set ||= data_sets.detect { |ds| ds.version == self.active_data_set_version }
  end

  def latest_data_set
    data_sets.order(version: "desc").first
  end

  def create_first_data_set
    unless self.persisted? or self.data_sets.any?
      self.data_sets << DataSet.new
    end
  end
end
