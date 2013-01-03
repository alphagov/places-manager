class BusinessSupportFacetManager 

  def self.facet_ids_to_slugs
    BusinessSupportScheme.all.each do |scheme|
      puts "Checking #{scheme.title} for facet ids"
      if has_facet_ids?(scheme)
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
        if scheme.business_support_purpose_ids.present?
          scheme.purposes = []
          scheme.business_support_purpose_ids.each do |id|
            purpose = BusinessSupportPurpose.find(id)
            if purpose
              scheme.purposes << purpose.slug
            end
          end
          scheme.business_support_purpose_ids = nil
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
      end
    end
    clear_facet_relations
  end

  def self.clear_facet_relations
    [
      BusinessSupportBusinessType.all, BusinessSupportLocation.all, BusinessSupportPurpose.all,
      BusinessSupportSector.all, BusinessSupportStage.all, BusinessSupportType.all
    ].flatten.each do |facet|
      
        if facet.business_support_scheme_ids.present?
          facet.business_support_scheme_ids = nil
          facet.save!
        end

      end
  end

  def self.has_facet_ids?(scheme)
    scheme.business_support_business_type_ids.present? or
    scheme.business_support_location_ids.present? or
    scheme.business_support_purpose_ids.present? or
    scheme.business_support_sector_ids.present? or
    scheme.business_support_stage_ids.present? or
    scheme.business_support_type_ids.present?
  end
end
