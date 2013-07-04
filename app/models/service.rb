class Service
  include Mongoid::Document
  include Sidekiq::Delay

  field :name,                    :type => String
  field :slug,                    :type => String
  field :active_data_set_version, :type => Integer, :default => 1
  field :source_of_data,          :type => String

  embeds_many :data_sets do
    def current
      where(:state.ne => 'archived')
    end
  end

  index({:slug => 1}, {:unique => true})

  validates_presence_of :name

  # underscore allowed because one of the existing services uses them in its slug.
  validates :slug, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9_-]*\z/ }

  before_validation :create_first_data_set, :on => :create
  after_save :schedule_csv_processing

  def reconcile_place_locations
    data_sets.first.places.map(&:reconcile_location)
  end

  def data_file=(file)
    ds = self.data_sets.build
    ds.data_file = file
    @need_csv_processing = true
  end

  def schedule_csv_processing
    if @need_csv_processing
      self.delay.process_csv_data(latest_data_set.version)
      @need_csv_processing = false
    end
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

  def schedule_archive_places
    obsolete_data_sets.each {|ds| ds.archive! if ds.places.any? }
    self.delay.archive_places
  end

  def archive_places
    obsolete_data_sets.each {|ds| ds.archive_places if ds.places.any? }
  end

  # returns all data sets up to but not including the data set before the active set
  def obsolete_data_sets
    data_sets.take_while {|ds| ds != active_data_set }.slice(0...-1)
  end
end
