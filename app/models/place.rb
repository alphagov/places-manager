class Place
  include Mongoid::Document
  include GeoTools

  scope :needs_geocoding, where(:location.size => 0, :geocode_error.exists => false)
  scope :geocoded, where(:location.size => 2)

  embedded_in :data_set

  field :name,           :type => String
  field :source_address, :type => String
  field :address1,        :type => String
  field :address2,        :type => String
  field :town,           :type => String
  field :postcode,       :type => String
  field :access_notes,   :type => String
  field :general_notes,  :type => String
  field :url,            :type => String
  field :phone,          :type => String
  field :fax,            :type => String
  field :text_phone,     :type => String
  field :location,       :type => Array, :geo => true, :default => []
  field :geocode_error,  :type => String

  attr_accessor :distance
  
  def geocode
    if location.nil? or location.empty?
      lookup = Geogov.lat_lon_from_postcode(self.postcode)
      if lookup
        self.location = lookup.values
      else
        self.geocode_error = "#{self.postcode} not found for #{self.full_address}"
      end
    end
  rescue => e
    error = "Error geocoding place #{self.postcode} : #{e.message}"
    Rails.logger.warn error
    self.geocode_error = error
  end
  
  def geocode!
    geocode
    save!
  end
  
  def address
    [address1, address2].select(&:present?).map(&:strip).join(', ')
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
