require "gds_api/test_helpers/organisations"

module GdsApiHelper
  include WebMock::API
  include GdsApi::TestHelpers::Organisations

  def stub_organisations_test_department
    stub_organisations_api_has_organisations_with_bodies([{ "title" => "Department of Testing", "details" => { "slug" => "test-department" } }])
  end

  def stub_search_finds_no_govuk_pages
    stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place").to_return(status: 200, body: { results: [] }.to_json, headers: {})
  end
end

World(GdsApiHelper)
