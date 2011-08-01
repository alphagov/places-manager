class Place
  include Mongoid::Document
  
  field :name,          :type => String
  field :address,       :type => String
  field :town,          :type => String
  field :postcode,      :type => String
  field :access_notes,  :type => String
  field :general_notes, :type => String
  field :url,           :type => String
  field :location,      :type => Array, :geo => true, :lat => :latitude, :lng => :longitude
  
  before_save :geocode!
  
  def geocode!
    if location.nil? or location.empty?
      require 'graticule'
      geocoder = Graticule.service(:google).new(GOOGLE_API_KEY)
      this_location = geocoder.locate(full_address)
      self.location = [this_location.latitude, this_location.longitude]
    end
  end
  
  def full_address
    [address, town, postcode, 'UK'].select { |i| i.present? }.join(', ')
  end
end
