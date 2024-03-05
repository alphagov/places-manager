desc "Updates Service records with titles/links to the GOV.UK place documents"
task service_urls_from_govuk: :environment do
  content_store_api = GdsApi.content_store
  place_pages = GdsApi.search.search({ filter_format: "place", count: 200, fields: "title,link,content_id" })

  place_pages["results"].each do |pp|
    ci = content_store_api.content_item(pp["link"])
    slug =  ci.to_hash["details"]["place_type"]
    service = Service.where(slug:).first
    if service
      Rails.logger.info("Adding #{pp['title']} to #{slug}")
      service.govuk_url = pp["link"]
      service.govuk_title = pp["title"]
      service.save!
    else
      Rails.logger.warn("Service slug #{slug} referenced in path #{pp['link']} does not exist!")
    end
  end
end
