class BusinessSupportFacetManager 

  def self.populate_empty_collections

    business_types = BusinessSupportBusinessType.all
    locations = BusinessSupportLocation.all
    sectors = BusinessSupportSector.all
    stages = BusinessSupportStage.all
    types = BusinessSupportType.all

    BusinessSupportScheme.all.each do |scheme|

      if has_empty_relations?(scheme)

        if scheme.business_support_locations.empty?
          scheme.business_support_locations = locations
          puts "Added all locations to #{scheme.title}"
        end
        if scheme.business_support_business_types.empty?
          scheme.business_support_business_types = business_types
          puts "Added all business_types to #{scheme.title}"
        end
        if scheme.business_support_sectors.empty?
          scheme.business_support_sectors = sectors
          puts "Added all sectors to #{scheme.title}"
        end
        if scheme.business_support_stages.empty?
          scheme.business_support_stages = stages
          puts "Added all stages to #{scheme.title}"
        end
        if scheme.business_support_types.empty?
          scheme.business_support_types = types
          puts "Added all types to #{scheme.title}"
        end
      
        scheme.save!
      
      end
    end
  end

  def self.associate_all_english_regions
    england = BusinessSupportLocation.where(slug: "england").first
    english_regions = BusinessSupportLocation.where(
      slug: /london|north-east|north-west|east-midlands|west-midlands|yorkshire-and-the-humber|south-west|east-of-england|south-east/)

    england.business_support_schemes.each do |scheme|
      scheme.business_support_locations << english_regions
      scheme.save!
    end
  end

  def self.has_empty_relations?(scheme)
    scheme.business_support_locations.empty? or
    scheme.business_support_business_types.empty? or
    scheme.business_support_sectors.empty? or
    scheme.business_support_stages.empty? or
    scheme.business_support_types.empty?
  end
end
