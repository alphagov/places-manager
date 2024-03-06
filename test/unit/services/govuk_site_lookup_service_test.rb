require "test_helper"

class GovukSiteLookupServiceTest < ActiveSupport::TestCase
  setup do
    search_results = {
      results: [
        { title: "Test Service", link: "/test-service-page" },
      ],
    }
    stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place")
      .to_return(status: 200, body: search_results.to_json, headers: {})

    content_item = {
      details: {
        place_type: "test-service",
      },
    }
    stub_request(:get, "http://content-store.dev.gov.uk/content/test-service-page")
      .to_return(status: 200, body: content_item.to_json, headers: {})
  end

  test "#govuk_page? returns true if page in search" do
    assert_equal(true, GovukSiteLookupService.new.govuk_page?("test-service"))
  end
  test "#govuk_page? returns false if page in search" do
    assert_equal(false, GovukSiteLookupService.new.govuk_page?("missing-service"))
  end

  test "#page_link returns full url of frontend page" do
    assert_equal("http://www.dev.gov.uk/test-service-page", GovukSiteLookupService.new.page_link("test-service"))
  end

  test "#page_title returns title of frontend page" do
    assert_equal("Test Service", GovukSiteLookupService.new.page_title("test-service"))
  end
end
