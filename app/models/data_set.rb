require 'csv'

class DataSet
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :service
  embeds_many :places
  embeds_many :actions
  
  field :version, :type => Integer, :default => 1
  before_save :set_version, :on => :create

  def set_version
    if self.version.blank? or self.version == 1
      self.version = service.data_sets.count + 1
    end
  end
  
  def data_file=(file)
    CSV.parse(file.read, :headers => true) do |row|
      places << Place.new(
        :name => row['name'],
        :address => row['address'],
        :town => row['town'],
        :postcode => row['postcode'],
        :access_notes => row['access_notes'],
        :general_notes => row['general_notes'],
        :url => row['url']
      )
    end
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
  
  def places_near(lat, lng, opts = {})
    ordered_places = places.select { |p| p.location }.sort_by { |p| p.distance_from(lat, lng) }
    if opts[:limit]
      ordered_places.slice(0, opts[:limit].to_i)
    elsif opts[:max_distance]
      ordered_places.select { |p| p.distance <= opts[:max_distance].to_f }
    end
  end
  
  def to_csv
    headers = ['name', 'address', 'town', 'postcode', 'access_notes', 'general_notes', 'url', 'lat', 'lng', 'phone', 'fax', 'text_phone']
    CSV.generate do |csv|
      csv << headers
      places.each do |place|
        csv << headers.collect { |h| place.send(h.to_sym) }
      end
    end
  end
end
