class IntroduceBusinessSizeFacet < Mongoid::Migration
  def self.up
    BusinessSupportScheme.all.each do |scheme|
      scheme.add_to_set(
        :business_sizes,
        [
          "under-10",
          "up-to-249",
          "between-250-and-500",
          "between-501-and-1000",
          "over-1000"
        ]
      )
    end
  end

  def self.down
  end
end
