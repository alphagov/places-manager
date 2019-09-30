class Point
  attr_reader :longitude, :latitude
  alias :lat :latitude
  alias :lng :longitude

  def initialize(coordinates)
    %i[longitude latitude].each do |key|
      # The Float method would fail with a TypeError, but this is more useful
      raise ArgumentError, "Missing #{key}" unless coordinates.has_key? key
    end

    @longitude, @latitude = %i[longitude latitude].map { |key|
      Float(coordinates[key])
    }
    unless (-90..90).include? @latitude # [-90, 90]
      raise "Invalid latitude #{@latitude.inspect}"
    end
    unless (-180...180).include? @longitude # [-180, 180)
      raise "Invalid longitude #{@longitude.inspect}"
    end
  end

  def ==(other)
    longitude == other.longitude && latitude == other.latitude
  rescue NoMethodError
    false
  end

  # Methods to allow Points to be stored in a mongo DB.
  # See http://mongoid.org/en/mongoid/docs/documents.html#custom_fields

  # Converts an object of this instance into a database friendly value.
  def mongoize
    { "longitude" => longitude, "latitude" => latitude }
  end

  class << self
    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(value)
      if value.nil?
        nil
      elsif value.is_a? Array
        legacy_demongoize value
      else
        new(longitude: value["longitude"], latitude: value["latitude"])
      end
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(value)
      if value.is_a?(Point)
        value.mongoize
      elsif value.is_a?(Hash)
        new(value.symbolize_keys).mongoize
      else
        value
      end
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(value)
      return value.mongoize if value.is_a?(Point)

      value
    end

  private

    def legacy_demongoize(value)
      # Legacy [lat, lng] data format
      # An empty array is considered a nil value
      case value.size
      when 2
        new(latitude: value[0], longitude: value[1])
      when 0
        nil
      else
        Rails.logger.error "Invalid location #{value.inspect}"
        nil
      end
    end
  end
end
