class Point

  attr_reader :longitude, :latitude

  def initialize(coordinates)
    [:longitude, :latitude].each do |key|
      # The Float method would fail with a TypeError, but this is more useful
      raise ArgumentError, "Missing #{key}" unless coordinates.has_key? key
    end

    @longitude, @latitude = [:longitude, :latitude].map { |key|
      Float(coordinates[key])
    }
    unless (-90..90).include? @latitude  # [-90, 90]
      raise "Invalid latitude #{@latitude.inspect}"
    end
    unless (-180...180).include? @longitude  # [-180, 180)
      raise "Invalid longitude #{@longitude.inspect}"
    end
  end

  def ==(other)
    longitude == other.longitude && latitude == other.latitude
  rescue NoMethodError
    false
  end

end
