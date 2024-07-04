class ServiceDataSetsTablePresenter
  def initialize(service, view_context)
    @service = service
    @view_context = view_context
  end

  def rows
    @service.data_sets.current.order(version: :asc).map do |data_set|
      data_set_presenter = DataSetPresenter.new(data_set)
      [
        { text: data_set_presenter.use_tag.html_safe },
        { text: data_set.version },
        { text: data_set.created_at.to_date.to_fs(:govuk_date) },
        { text: data_set.places.count },
        { text: data_set_presenter.status_tag.html_safe },
        { text: @view_context.link_to("View", @view_context.admin_service_data_set_path(service_id: data_set.service_id, id: data_set.id), class: "govuk-link").html_safe },
      ]
    end
  end

  def headers
    [
      {
        text: "Use",
      },
      {
        text: "Version",
      },
      {
        text: "Uploaded At",
      },
      {
        text: "Places",
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
