module ErrorHelper
  def form_errors_for_field(form_errors, field_name)
    return [] unless form_errors

    form_errors.select { |v| v[:id] == field_name }.map { |v| { text: v[:text], error_id: v[:href] } }
  end
end
