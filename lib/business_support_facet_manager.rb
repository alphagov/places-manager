class BusinessSupportFacetManager 

  def self.populate_empty_collections

    business_types = BusinessSupportBusinessType.all.asc(:name)
    locations = BusinessSupportLocation.all.asc(:name)
    sectors = BusinessSupportSector.all.asc(:name)
    stages = BusinessSupportStage.all.asc(:name)
    types = BusinessSupportType.all.asc(:name)

    BusinessSupportScheme.all.each do |scheme|

      if has_empty_relations?(scheme)

        if scheme.locations.empty?
          scheme.locations = locations.map(&:slug)
          puts "Added all locations to #{scheme.title}"
        end
        if scheme.business_types.empty?
          scheme.business_types = business_types.map(&:slug)
          puts "Added all business_types to #{scheme.title}"
        end
        if scheme.sectors.empty?
          scheme.sectors = sectors.map(&:slug)
          puts "Added all sectors to #{scheme.title}"
        end
        if scheme.stages.empty?
          scheme.stages = stages.map(&:slug)
          puts "Added all stages to #{scheme.title}"
        end
        if scheme.support_types.empty?
          scheme.support_types = types.map(&:slug)
          puts "Added all types to #{scheme.title}"
        end
      
        scheme.save!
      
      end
    end
  end

  def self.facet_ids_to_slugs
    BusinessSupportScheme.all.each do |scheme|
      puts "Checking #{scheme.title} for facet ids"
      if has_facet_ids?(scheme)
        puts scheme.inspect
        if scheme.business_support_business_type_ids.present?
          scheme.business_types = []
          scheme.business_support_business_type_ids.each do |id|
            business_type = BusinessSupportBusinessType.find(id)
            if business_type
              scheme.business_types << business_type.slug
            end
          end
          scheme.business_support_business_type_ids = nil
        end
        if scheme.business_support_location_ids.present?
          scheme.locations = []
          scheme.business_support_location_ids.each do |id|
            location = BusinessSupportLocation.find(id)
            if location
              scheme.locations << location.slug
            end
          end
          scheme.business_support_location_ids = nil
        end
        if scheme.business_support_sector_ids.present?
          scheme.sectors = []
          scheme.business_support_sector_ids.each do |id|
            sector = BusinessSupportSector.find(id)
            if sector
              scheme.sectors << sector.slug
            end
          end
          scheme.business_support_sector_ids = nil
        end
        if scheme.business_support_stage_ids.present?
          scheme.stages = []
          scheme.business_support_stage_ids.each do |id|
            stage = BusinessSupportStage.find(id)
            if stage
              scheme.stages << stage.slug
            end
          end
          scheme.business_support_stage_ids = nil        
        end
        if scheme.business_support_type_ids.present?
          scheme.support_types = []
          scheme.business_support_type_ids.each do |id|
            support_type = BusinessSupportType.find(id)
            if support_type
              scheme.support_types << support_type.slug
            end
          end
          scheme.business_support_type_ids = nil
        end
        scheme.save!
        puts scheme.inspect
      end
    end
    clear_facet_relations
  end

  def self.clear_facet_relations
    [BusinessSupportBusinessType.all, BusinessSupportLocation.all, BusinessSupportSector.all,
      BusinessSupportStage.all, BusinessSupportType.all].flatten.each do |facet|
      
        if facet.business_support_scheme_ids.present?
          facet.business_support_scheme_ids = nil
          facet.save!
        end

      end
  end

  def self.has_empty_relations?(scheme)
    scheme.locations.empty? or
    scheme.business_types.empty? or
    scheme.sectors.empty? or
    scheme.stages.empty? or
    scheme.support_types.empty?
  end

  def self.has_facet_ids?(scheme)
    scheme.business_support_business_type_ids.present? or
    scheme.business_support_location_ids.present? or
    scheme.business_support_sector_ids.present? or
    scheme.business_support_stage_ids.present? or
    scheme.business_support_type_ids.present?
  end
end
