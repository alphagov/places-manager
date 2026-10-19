# The test environment expects an empty test database. These seeds are used
# to set up the minimum for a dev environment and are used with
# https://github.com/alphagov/govuk-preview-app

return if Rails.env.test?

if User.where(name: "Test user").blank?
  gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"
  User.create!(
    name: "Test user",
    permissions: ["signin", "GDS Editor"],
    organisation_content_id: gds_organisation_id,
    organisation_slug: "government-digital-service",
  )
end
