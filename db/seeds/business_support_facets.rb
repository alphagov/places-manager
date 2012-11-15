def find_or_initialize_facets(klass, facet_names)
  facet_names.each do |slug, name|
    facet = klass.find_or_initialize_by(:slug => slug, :name => name)
    facet.save
  end
end

# BusinessSupportBusinessType
find_or_initialize_facets(BusinessSupportBusinessType, 
                         {"private-company"         => "Private Company", 
                          "public-limited-company"  => "Public limited company", 
                          "partnership"             => "Partnership", 
                          "social-enterprise"       => "Social enterprise", 
                          "charity"                 => "Charity", 
                          "sole-trader"             => "Sole trader"})

# BusinessSupportLocation
find_or_initialize_facets(BusinessSupportLocation,
                          { "northern-ireland" => "Northern Ireland", 
                            "england"          => "England",
                            "london" => "London",
                            "north-east" => "North East (England)",
                            "north-west" => "North West (England)",
                            "east-midlands" => "East Midlands (England)",
                            "west-midlands" => "West Midlands (England)",
                            "yorkshire-and-the-humber" => "Yorkshire and the Humber",
                            "south-west" => "South West (England)",
                            "east-of-england" => "East of England",
                            "south-east" => "South East (England)",
                            "wales"            => "Wales", 
                            "scotland"         => "Scotland"})

# BusinessSupportSector
find_or_initialize_facets(BusinessSupportSector,
                          {"wholesale-and-retail" => "Wholesale and Retail", 
                           "manufacturing" => "Manufacturing", 
                           "hospitality-and-catering" => "Hospitality and Catering", 
                           "travel-and-leisure" => "Travel and Leisure",
                           "agriculture" => "Agriculture", 
                           "construction" => "Construction", 
                           "information-communication-and-media" => "Information, Communication and Media", 
                           "science-and-technology" => "Science and Technology",
                           "transport-and-distribution" => "Transport and Distribution",
                           "utilities" => "Utilities",
                           "business-and-finance" => "Business and Finance",
                           "education" => "Education",
                           "health" => "Health",
                           "service-industries" => "Service Industries",
                           "mining" => "Mining",
                           "real-estate" => "Real Estate"})

# BusinessSupportStage
find_or_initialize_facets(BusinessSupportStage, {
                          "pre-startup" => "Pre-startup",
                          "start-up" => "Start-up",
                          "grow-and-sustain" => "Grow and sustain",
                          "exiting-a-business" => "Exiting a business"})

# BusinessSupportType
find_or_initialize_facets(BusinessSupportType, {
                          "grant" => "Grant",
                          "finance" => "Finance",
                          "loan" => "Loan",
                          "expertise-and-advice" => "Expertise and Advice",
                          "recognition-award" => "Recognition Award",
                          "equity" => "Equity"})
