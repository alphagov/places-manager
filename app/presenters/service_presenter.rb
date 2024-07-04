class ServicePresenter
  def initialize(service)
    @service = service
    @active_data_set_presenter = DataSetPresenter.new(@service.active_data_set)
    @lookup = GovukSiteLookupService.new
  end

  def summary_list(view_context)
    summary_items = [
      { field: "Slug", value: @service.slug },
      { field: "Organisation Slugs", value: @service.organisation_slugs.join("<br />").html_safe },
      { field: "GOV.UK page", value: page_link(view_context) },
      { field: "Source of data", value: @service.source_of_data },
      { field: "Location match type", value: match_type },
      { field: "Active Data set version", value: @service.active_data_set.version },
      { field: "Places", value: @active_data_set_presenter.places_info },
      { field: "Status", value: active_data_set_status.html_safe },
    ]

    { items: summary_items }
  end

  def active_data_set_status
    @active_data_set_presenter.status_tag
  end

  def match_type
    return "Nearest" if @service.location_match_type == "nearest"

    "Local Authority / #{@service.local_authority_hierarchy_match_type}"
  end

  def page_link(view_context)
    return "Not used on GOV.UK" unless @lookup.govuk_page?(@service.slug)

    view_context.link_to(@lookup.page_title(@service.slug), @lookup.page_link(@service.slug), class: "govuk-link")
  end
end
