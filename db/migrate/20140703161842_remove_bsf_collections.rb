class RemoveBsfCollections < Mongoid::Migration

  COLLECTIONS_TO_REMOVE = ["business_support_types", "business_support_support_types",
    "business_support_schemes", "business_support_business_types",
    "business_support_sectors", "business_support_locations",
    "business_support_purposes", "business_support_business_sizes",
    "business_support_stages"]

  def self.up
    Mongoid::Threaded.sessions.values.each do |session|
      session.collections.select { |c| COLLECTIONS_TO_REMOVE.include?(c.name) }.map(&:drop)
    end
  end

  def self.down
  end
end
