require "gds_api/test_helpers/organisations"

module OrganisationHelper
  include GdsApi::TestHelpers::Organisations

  def stub_organisations_test_department
    stub_organisations_api_has_organisations_with_bodies([{ "title" => "Department of Testing", "details" => { "slug" => "test-department" } }])
  end
end

RSpec.configuration.include OrganisationHelper
