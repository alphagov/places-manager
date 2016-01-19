class UpdateIncorrectBusinessSizeFacet < Mongoid::Migration
  def self.up
    return unless defined?(BusinessSupport) && defined?(BusinessSupport::BusinessSize)
    BusinessSupport::BusinessSize.where(name: "Between 501 and 1000").update(slug: "between-501-and-1000")
  end

  def self.down
  end
end
