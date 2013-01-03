require 'business_support_facet_manager'

namespace :business_support_facets do
  desc "Switches facet ids for facet slugs in business support schemes"
  task :facet_ids_to_slugs => :environment do
    BusinessSupportFacetManager.facet_ids_to_slugs
  end
end
