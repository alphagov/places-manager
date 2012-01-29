class Service
  include Mongoid::Document

  field :name,                    :type => String
  field :slug,                    :type => String
  field :active_data_set_version, :type => Integer, :default => 1

  embeds_many :data_sets

  validates_presence_of :name
  validates_presence_of :slug

  after_initialize :create_first_data_set

  def data_file=(file)
    ds_version = self.data_sets.any? ? self.data_sets.last.version + 1 : 1
    d = DataSet.new(:version => ds_version, :data_file => file)
    self.data_sets << d
  end

  def active_data_set
    @active_data_set ||= data_sets.detect { |ds| ds.version == self.active_data_set_version }
  end

  def create_first_data_set
    unless self.persisted? or self.data_sets.any?
      self.data_sets << DataSet.new
    end
  end
end
