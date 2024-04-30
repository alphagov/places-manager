def stub_search_finds_no_govuk_pages
  stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place").to_return(status: 200, body: { results: [] }.to_json, headers: {})
end
