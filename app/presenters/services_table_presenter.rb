class ServicesTablePresenter
  def initialize(services, view_context)
    @services = services
    @view_context = view_context
    @lookup = GovukSiteLookupService.new
  end

  def rows
    @services.map do |service|
      presenter = ServicePresenter.new(service)
      [
        { text: service.name },
        { text: page_title(service) },
        { text: service.active_data_set.places.count, format: "numeric" },
        { text: presenter.active_data_set_status.html_safe },
        { text: @view_context.link_to("Edit", @view_context.admin_service_path(service), class: "govuk-link") },
      ]
    end
  end

  def headers
    [
      {
        text: "Service Name",
      },
      {
        text: "Page title on GOV.UK",
      },
      {
        text: "Places",
        format: "numeric",
      },
      {
        text: "Status",
      },
      {
        text: "",
      },
    ]
  end

private

  def page_title(service)
    return "Not used on GOV.UK" unless @lookup.govuk_page?(service.slug)

    @lookup.page_title(service.slug)
  end
end
