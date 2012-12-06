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

  def self.associate_english_regions
    updated = []
    failed = []
    not_found = []
    england = BusinessSupportLocation.where(slug: "england").first

    # Update schemes from legacy data with the relevant regions.
    #
    english_regional_data.each do |row|
      scheme = BusinessSupportScheme.where(business_support_identifier: row["id"]).first
      if scheme
        location = BusinessSupportLocation.where(name: row["region"]).first
    
        if scheme.business_support_locations == [england]
          scheme.business_support_locations = []
        end
      
        scheme.business_support_locations << location
        scheme.save ? updated << scheme : failed << scheme
      else
        not_found << row["id"]
      end
    end

    # Update all schemes associated to England with all english regions.
    #
    english_regions = BusinessSupportLocation.where(
      slug: /london|north-east|north-west|east-midlands|west-midlands|yorkshire-and-the-humber|south-west|east-of-england|south-east/)

    england.reload

    england.business_support_schemes.each do |scheme|
      scheme.business_support_locations << english_regions
      scheme.save ? updated << scheme : failed << scheme
    end
    
    updated.uniq!
    not_found.uniq!
    failed.uniq!

    puts "Successfully updated #{updated.size} schemes"
    if not_found.size > 0
      puts "#{not_found.size} schemes could not be found:"
      puts not_found.join(", ")
    end
    if failed.size > 0
      puts "#{failed.size} schemes failed to update:"
      puts failed.map(&:title)
    end
  end

  def self.english_regional_data
    CSV.read(File.join(Rails.root, "data", "business-support-schemes-england-regional.csv"), headers: true)
  end

  def self.has_empty_relations?(scheme)
    scheme.business_support_locations.empty? or
    scheme.business_support_business_types.empty? or
    scheme.business_support_sectors.empty? or
    scheme.business_support_stages.empty? or
    scheme.business_support_types.empty?
  end
end
