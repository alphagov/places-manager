class AmbiguousPostcodeError < StandardError
  attr_reader :addresses

  def initialize(addresses)
    super()
    @addresses = addresses
  end
end
