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
        { text: @view_context.link_to(service.name, @view_context.admin_service_path(service)) },
        { text: page_link(service) },
        { text: service.active_data_set.places.count, format: "numeric" },
        { text: presenter.active_data_set_status.html_safe },
      ]
    end
  end

  def headers
    [
      {
        text: "Service",
      },
      {
        text: "GOV.UK pages",
      },
      {
        text: "Places",
        format: "numeric",
      },
      {
        text: "Status",
      },
    ]
  end

private

  def page_link(service)
    return "Not used on GOV.UK" unless @lookup.govuk_page?(service.slug)

    @view_context.link_to(@lookup.page_title(service.slug), @lookup.page_link(service.slug))
  end
end
