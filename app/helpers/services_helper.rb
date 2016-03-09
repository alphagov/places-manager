module ServicesHelper
  def service_location_match_type_options
    Service::LOCATION_MATCH_TYPES.map { |location_match_type| [location_match_type.humanize, location_match_type] }
  end

  def service_local_authority_hierarchy_match_type_options
    Service::LOCAL_AUTHORITY_HIERARCHY_MATCH_TYPES.map { |match_type| [match_type.humanize, match_type] }
  end
end
