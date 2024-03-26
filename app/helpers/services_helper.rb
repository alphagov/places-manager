module ServicesHelper
  def service_location_match_type_options(current_value)
    Service::LOCATION_MATCH_TYPES.map { |location_match_type| { text: location_match_type.humanize, value: location_match_type, selected: current_value == location_match_type } }
  end

  def service_local_authority_hierarchy_match_type_options(current_value)
    Service::LOCAL_AUTHORITY_HIERARCHY_MATCH_TYPES.map { |match_type| { text: match_type.humanize, value: match_type, selected: current_value == match_type } }
  end
end
