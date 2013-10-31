class UpdateIncorrectBusinessSizeFacet < Mongoid::Migration
  def self.up
    BusinessSupport::BusinessSize.where(name: "Between 501 and 1000").update(slug: "between-501-and-1000")
  end

  def self.down
  end
end