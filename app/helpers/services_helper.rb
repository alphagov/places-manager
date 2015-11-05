module ServicesHelper
  def service_location_match_type_options
    Service::LOCATION_MATCH_TYPES.map { |location_match_type| [location_match_type.humanize, location_match_type] }
  end
end
