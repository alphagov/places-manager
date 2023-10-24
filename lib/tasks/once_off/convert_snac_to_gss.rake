namespace :once_off do
  desc "Creates duplicate datasets with GSS codes instead of SNACs for local authority data_sets"
  task convert_snac_to_gss: [:environment] do
    snac_to_gss_lookup = load_snac_to_gss_lookup

    affected_services.each do |service|
      puts("INFO: Updating Service: #{service.slug}")
      duplicate = service.active_data_set.duplicate

      duplicate.change_notes += ", then updated by once_off:convert_snac_to_gss task"
      duplicate.save!

      duplicate.places.each do |place|
        next if already_gss?(place.gss)

        snac = place.gss
        gss = snac_to_gss_lookup[snac]
        if gss.nil?
          puts(" - ERROR: Failed to update SNAC #{snac} for #{service.slug}")
        else
          place.gss = gss
          place.save!
        end
      end
    end
  end
end

def load_snac_to_gss_lookup
  lookup_cache = {}
  CSV.foreach("lib/tasks/once_off/snac_to_gss_translation.csv") do |row|
    lookup_cache[row[0]] = row[1]
  end
  lookup_cache
end

def affected_services
  Service.where(location_match_type: "local_authority")
end

def already_gss?(code)
  code.length > 4
end
