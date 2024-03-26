class PlacePresenter
  attr_reader :place

  def initialize(place)
    @place = place
  end

  def summary_list(view_context)
    summary_items = [
      { field: "Status", value: status_tag.html_safe },
      { field: "Geocode Error Details", value: place.geocode_error },
      { field: "Full Address", value: place.full_address },
      { field: "Address 1", value: place.address1 },
      { field: "Address 2", value: place.address2 },
      { field: "Town", value: place.town },
      { field: "Postcode", value: place.postcode },
      { field: "Access Notes", value: place.access_notes },
      { field: "General Notes", value: place.general_notes },
      { field: "URL", value: view_context.link_to(place.url, place.url).html_safe },
      { field: "Email", value: view_context.link_to(place.email, "mailto:#{place.email}").html_safe },
      { field: "Phone", value: place.phone },
      { field: "Fax", value: place.fax },
      { field: "Text Phone", value: place.text_phone },
      { field: "Geocoded Location", value: location_value },
      { field: "Override Location", value: override_location_value },
      { field: "GSS", value: place.gss },
      { field: "Source Address", value: place.source_address },
      { field: "Last Updated", value: place.updated_at },
    ]

    { items: summary_items }
  end

  def location_value
    rounded_for_display(place.lat, place.lng) if place.lat && place.lng
  end

  def override_location_value
    rounded_for_display(place.override_lat, place.override_lng) if place.override_lat && place.override_lng
  end

  def location_summary
    return place.gss || "<em>&mdash;</em>" unless place.data_set.service.location_match_type == "nearest"

    location_value || "<em>&mdash;</em>"
  end

  def status_tag
    tag_parts = { color: "green", text: "Good" }
    tag_parts = { color: "red", text: "Geocode Error" } if place.geocode_error

    "<span class=\"govuk-tag govuk-tag--#{tag_parts[:color]}\">#{tag_parts[:text]}</span>"
  end

private

  def rounded_for_display(lat, lng)
    "#{lat.round(4)}, #{lng.round(4)}"
  end
end
