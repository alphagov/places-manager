class GovukSiteLookupService
  def govuk_page?(slug)
    public_url_info.key?(slug)
  end

  def page_link(slug)
    public_url_info[slug][:link]
  end

  def page_title(slug)
    public_url_info[slug][:title]
  end

  def public_url_info
    Rails.cache.fetch("imminence_public_url_info", expires_in: 5.minutes) do
      content_store_api = GdsApi.content_store
      place_pages = GdsApi.search.search({ filter_format: "place", count: 200, fields: "title,link" })

      place_pages["results"].each_with_object({}) do |pp, hash|
        ci = content_store_api.content_item(pp["link"])
        slug = ci["details"]["place_type"]
        hash[slug] = { link: Plek.website_root + pp["link"], title: pp["title"] }
      end
    end
  end
end
