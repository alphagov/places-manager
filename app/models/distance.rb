class Distance
  attr_reader :magnitude, :unit

  # Degrees and radians are for the surface of an idealised, spherical Earth.
  #
  # Also worth noting: the degrees and radians are only applicable when used on
  # a great circle between two points on a sphere: if you use them with degrees
  # of longitude at any point other than the Equator, you will get incorrect
  # results.
  EARTH_RADIUS_IN_MILES = 3963.19
  UNITS = %i[miles degrees radians]

  # <value> in units of <key> is equal for each pair here
  EQUIVALENTS = {
    miles: EARTH_RADIUS_IN_MILES,
    degrees: 360 / (2 * Math::PI),
    radians: 1,
  }

  def initialize(magnitude, unit)
    raise "Invalid unit #{unit.inspect}" unless UNITS.include? unit
    raise "#{magnitude.inspect} is not a number" unless magnitude.is_a? Numeric
    @magnitude = magnitude
    @unit = unit
  end

  # Define class methods for each distance unit. For example, the code:
  #
  #   Distance.miles(500)
  #
  # is equivalent to:
  #
  #   Distance.new(500, :miles)
  class << self
    UNITS.each do |unit|
      define_method unit do |magnitude|
        self.new magnitude, unit
      end
    end
  end

  def to_s
    "#{@magnitude} #{@unit}"
  end

  def ==(other)
    # Thanks to the inaccuracy of floating-point arithmetic, we can't reliably
    # define a symmetric and transitive equality relation between distances of
    # different units
    magnitude == other.magnitude && unit == other.unit
  rescue NoMethodError
    false
  end

  def in(unit)
    @magnitude * Distance.conversion_ratio(@unit, unit)
  end

  # "in" is a reserved word in Ruby, for use in the "for...in" syntax. Aliasing
  # the method means people can use the alternative form in situations where
  # "in" would cause problems
  alias_method :in_unit, :in

  def self.conversion_ratio(from_unit, to_unit)
    EQUIVALENTS[to_unit] / EQUIVALENTS[from_unit]
  end
end
