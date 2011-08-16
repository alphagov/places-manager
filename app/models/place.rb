class Place
  include Mongoid::Document
  include GeoTools

  embedded_in :data_set

  field :name,          :type => String
  field :address,       :type => String
  field :town,          :type => String
  field :postcode,      :type => String
  field :access_notes,  :type => String
  field :general_notes, :type => String
  field :url,           :type => String
  field :phone,         :type => String
  field :fax,           :type => String
  field :text_phone,    :type => String
  field :location,      :type => Array, :geo => true, :lat => :latitude, :lng => :longitude

  index [[ :location, Mongo::GEO2D ]], :min => -180, :max => 180
  before_save :geocode
  attr_accessor :distance
  
  def geocode
    if location.nil? or location.empty?
      lookup = Geogov.lat_lon_from_postcode(self.postcode)
      self.location = lookup.values
    end
  rescue => e
    Rails.logger.warn "Error geocoding place #{self.postcode} : #{e.message}"
  end
  
  def geocode!
    geocode
    save!
  end
  
  def full_address
    [address, town, postcode, 'UK'].select { |i| i.present? }.map(&:strip).join(', ')
  end

  def distance_from(lat, lng)
    from = {'lat' => location[0], 'lng' => location[1]}
    to = {'lat' => lat, 'lng' => lng}
    @distance ||= distance_between(from, to)
  end
  
  def to_s
    [name, full_address, url].select(&:present?).join(', ')
  end
  
  def lat
    location.nil? ? nil : location[0]
  end
  
  def lng
    location.nil? ? nil : location[1]
  end
end
