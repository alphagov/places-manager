class PlacesTablePresenter
  def initialize(data_set, places, view_context)
    @places = places
    @view_context = view_context
    @is_nearest = data_set.service.location_match_type == "nearest"
  end

  def rows
    @places.map do |place|
      presenter = PlacePresenter.new(place)
      [
        { text: @view_context.truncate(place.name, length: 30) || "<em>&mdash;</em>".html_safe },
        { text: @view_context.truncate(place.full_address, length: 30) || "<em>&mdash;</em>".html_safe },
        { text: @view_context.truncate(place.url, length: 40) || "<em>&mdash;</em>".html_safe },
        { text: presenter.location_summary.html_safe },
        { text: presenter.status_tag.html_safe },
        { text: @view_context.link_to("View", @view_context.admin_service_data_set_place_path(place.data_set.service, place.data_set, place)) },
      ]
    end
  end

  def headers
    [
      {
        text: "Name",
      },
      {
        text: "Address",
      },
      {
        text: "URL",
      },
      {
        text: @is_nearest ? "Location" : "GSS",
      },
      {
        text: "Status",
      },
      {
        text: "",
      },
    ]
  end
end
