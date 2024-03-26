class DataSetPresenter
  def initialize(data_set)
    @data_set = data_set
  end

  def summary_list(_view_context)
    summary_items = [
      { field: "Use", value: use_tag.html_safe },
      { field: "Uploaded", value: @data_set.created_at.to_date.to_fs(:govuk_date) },
      { field: "Change notes", value: @data_set.change_notes },
      { field: "Places", value: places_info },
      { field: "Status", value: status_tag.html_safe },
    ]

    { items: summary_items }
  end

  def use_tag
    tag_parts = { color: "grey", text: "Inactive" }
    tag_parts = { color: "green", text: "Active" } if @data_set.active?
    tag_parts = { color: "yellow", text: "Archiving" } if @data_set.archiving?

    "<span class=\"govuk-tag govuk-tag--#{tag_parts[:color]}\">#{tag_parts[:text]}</span>"
  end

  def status_tag
    if @data_set.processing_complete?
      tag_parts = { color: "green", text: I18n.t("presenters.data_set.status.ready") }
      tag_parts = { color: "yellow", text: I18n.t("presenters.data_set.status.some_problems") } if places_with_problems?
      tag_parts = { color: "red", text: I18n.t("presenters.data_set.status.no_places") } if @data_set.number_of_places.zero?
    else
      tag_parts = { color: "grey", text: I18n.t("presenters.data_set.status.processing") }
      tag_parts = { color: "red", text: @data_set.processing_error } if @data_set.processing_error.present?
    end

    "<span class=\"govuk-tag govuk-tag--#{tag_parts[:color]}\">#{tag_parts[:text]}</span>"
  end

  def places_info
    places = @data_set.places

    parts = []
    parts << "#{places.needs_geocoding.count} left to code" if places.needs_geocoding.any?
    parts << "#{places.with_geocoding_errors.count} with geocode errors" if places.with_geocoding_errors.any?
    parts << "#{places.missing_gss_codes.count} with missing GSS codes" if @data_set.service.uses_local_authority_lookup? && places.missing_gss_codes.any?

    parts.any? ? "#{places.count} (#{parts.join(', ')})" : places.count.to_s
  end

private

  def places_with_problems?
    return true if @data_set.places.with_geocoding_errors.any?
    return true if @data_set.service.uses_local_authority_lookup? && @data_set.places.missing_gss_codes.any?

    false
  end
end
