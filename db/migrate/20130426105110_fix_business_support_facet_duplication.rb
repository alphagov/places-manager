class FixBusinessSupportFacetDuplication < Mongoid::Migration
  def self.up
    return unless defined? BusinessSupportScheme

    BusinessSupportScheme.all.each do |scheme|
      scheme.business_types.uniq!
      scheme.locations.uniq!
      scheme.purposes.uniq!
      scheme.sectors.uniq!
      scheme.stages.uniq!
      scheme.support_types.uniq!
      scheme.save!
    end
  end

  def self.down
  end
end
