class Service
  include Mongoid::Document
  include Sidekiq::Delay

  field :name,                    :type => String
  field :slug,                    :type => String
  field :active_data_set_version, :type => Integer, :default => 1
  field :source_of_data,          :type => String

  embeds_many :data_sets

  index :slug, :unique => true

  validates_presence_of :name

  # underscore allowed because one of the existing services uses them in its slug.
  validates :slug, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9_-]*\z/ }

  before_validation :create_first_data_set, :on => :create

  after_save do |service|
    if Rails.env.development?
      process_csv_data(latest_data_set.version)
      latest_data_set.save! unless latest_data_set.persisted?
    else
      schedule_csv_processing 
    end
  end

  def reconcile_place_locations
    data_sets.first.places.map(&:reconcile_location)
  end

  def data_file=(file)
    ds = self.data_sets.build
    ds.data_file = file
  end

  def schedule_csv_processing
    self.delay.process_csv_data(latest_data_set.version)
  end

  def process_csv_data(data_set_version)
    self.data_sets.where(:version => data_set_version).first.process_csv_data
  end

  def active_data_set
    @active_data_set ||= data_sets.detect { |ds| ds.version == self.active_data_set_version }
  end

  def latest_data_set
    data_sets.order(version: "desc").first
  end

  def create_first_data_set
    unless self.data_sets.any?
      self.data_sets.build
    end
  end
end
