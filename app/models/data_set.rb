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
        :address1 => row['address1'],
        :address2 => row['address2'],
        :town => row['town'],
        :postcode => row['postcode'],
        :access_notes => row['access_notes'],
        :general_notes => row['general_notes'],
        :url => row['url'],
        :source_address => row['source_address']
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
    ordered_places = places.geocoded.sort_by { |p| p.distance_from(lat, lng) }
    if opts[:limit]
      ordered_places = ordered_places.slice(0, opts[:limit].to_i)
    elsif opts[:max_distance]
      ordered_places = ordered_places.select { |p| p.distance <= opts[:max_distance].to_f }
    end
    ordered_places
  end

  def to_csv
    CSV.generate do |csv|
      to_array_for_csv.each do |row|
        csv << row
      end
    end
  end

  def to_array_for_csv
    [].tap do |csv|
      headers = ['name', 'address1', 'address2', 'town', 'postcode', 'access_notes', 'general_notes', 'url', 'lat', 'lng', 'phone', 'fax', 'text_phone']
      csv << headers
      places.each do |place|
        csv << headers.collect { |h| place.send(h.to_sym) }
      end
    end
  end
end
