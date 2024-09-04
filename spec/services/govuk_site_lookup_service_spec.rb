require "rails_helper"

RSpec.describe(GovukSiteLookupService, type: :model) do
  let(:search_results) { { results: [{ title: "Test Service", link: "/test-service-page" }] } }

  before do
    stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place").to_return(status: 200, body: search_results.to_json, headers: {})
    content_item = { details: { place_type: "test-service" } }
    stub_request(:get, "http://content-store.dev.gov.uk/content/test-service-page").to_return(status: 200, body: content_item.to_json, headers: {})
    stub_request(:get, "http://content-store.dev.gov.uk/content/foooo").to_return(status: 404, body: "", headers: {})
  end

  describe "#govuk_page?" do
    it "returns true if page in search" do
      expect(GovukSiteLookupService.new.govuk_page?("test-service")).to(eq(true))
    end

    it "returns false if page in search" do
      expect(GovukSiteLookupService.new.govuk_page?("missing-service")).to(eq(false))
    end
  end

  describe "#page_link" do
    it "returns full url of frontend page" do
      expect(GovukSiteLookupService.new.page_link("test-service")).to(eq("http://www.dev.gov.uk/test-service-page"))
    end
  end

  describe "#page_title" do
    it "returns title of frontend page" do
      expect(GovukSiteLookupService.new.page_title("test-service")).to(eq("Test Service"))
    end
  end

  context "with items that are in search but missing from content-store" do
    let(:search_results) { { results: [{ title: "foo", link: "/foooo" }, { title: "Test Service", link: "/test-service-page" }] } }

    it "returns title of frontend page, ignoring the broken item" do
      expect(GovukSiteLookupService.new.page_title("test-service")).to(eq("Test Service"))
    end
  end
end
