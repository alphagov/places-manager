require 'test_helper'

class BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do
    agriculture = FactoryGirl.create(:business_support_sector, name: "Agriculture", slug: "agriculture")
    manufacturing = FactoryGirl.create(:business_support_sector, name: "Manufacturing", slug: "manufacturing")
    
    loan = FactoryGirl.create(:business_support_type, name: "Loan", slug: "loan")
    award = FactoryGirl.create(:business_support_type, name: "Award", slug: "award")
    
    scotland = FactoryGirl.create(:business_support_location, name: "Scotland", slug: "scotland")
    wales = FactoryGirl.create(:business_support_location, name: "Wales", slug: "wales")
    
    private_company = FactoryGirl.create(:business_support_business_type, name: "Private Company", slug: "private-company")
    charity = FactoryGirl.create(:business_support_business_type, name: "Charity", slug: "charity")
    
    under_10_emps = FactoryGirl.create(:business_support_business_size, name: "Under 10", slug: "under-10")
    up_to_249_emps = FactoryGirl.create(:business_support_business_size, name: "Up to 249", slug: "up-to-249")

    start_up = FactoryGirl.create(:business_support_stage, name: "Start-up", slug: "start-up")
    grow_sustain = FactoryGirl.create(:business_support_stage, name: "Grow and sustain", slug: "grow-and-sustain")
    
    eu_culture_programme = FactoryGirl.create(:business_support_scheme, title: "EU Culture Programme",
      business_support_identifier: "eu-culture-programme", priority: 0)
    urban_dev_grant = FactoryGirl.create(:business_support_scheme, title: "Urban Development Grant",
      business_support_identifier: "urban-development-grant", priority: 2)
    business_mentoring = FactoryGirl.create(:business_support_scheme, title: "Business Mentoring",
      business_support_identifier: "business-mentoring", priority: 1)
    sectorless_scheme = FactoryGirl.create(:business_support_scheme, title: "I have no sectors",
      business_support_identifier: "i-have-no-sectors", priority: 1)
    
    urban_dev_grant.sectors << agriculture.slug
    urban_dev_grant.sectors << manufacturing.slug
    urban_dev_grant.business_types << private_company.slug
    urban_dev_grant.business_sizes << under_10_emps.slug
    urban_dev_grant.locations << wales.slug
    urban_dev_grant.support_types << loan.slug
    urban_dev_grant.stages << start_up.slug
    
    eu_culture_programme.sectors << agriculture.slug
    eu_culture_programme.business_types << charity.slug
    eu_culture_programme.business_sizes << up_to_249_emps.slug
    eu_culture_programme.locations << scotland.slug
    eu_culture_programme.support_types << award.slug
    eu_culture_programme.stages << grow_sustain.slug
    
    business_mentoring.business_types << charity.slug
    business_mentoring.business_types << private_company.slug
    business_mentoring.business_sizes << under_10_emps.slug
    business_mentoring.business_sizes << up_to_249_emps.slug
    business_mentoring.locations << scotland.slug
    business_mentoring.locations << wales.slug
    business_mentoring.support_types << award.slug
    business_mentoring.support_types << loan.slug
    business_mentoring.stages << grow_sustain.slug
    
    sectorless_scheme.business_types << charity.slug
    sectorless_scheme.business_sizes << up_to_249_emps.slug
    sectorless_scheme.locations << scotland.slug
    sectorless_scheme.stages << start_up.slug

    eu_culture_programme.save!
    urban_dev_grant.save!
    business_mentoring.save!
    sectorless_scheme.save!

  end

  test "GET to index no params" do
    get :index, format: :json
    json = JSON.parse(response.body)
    assert_equal 4, json['total'].to_i
  end

  test "GET to index with gibberish params" do
    get :index, format: :json, sectors: 'foo,bar'
    result = JSON.parse(response.body)
    assert_equal 'ok', result['_response_info']['status']
    assert_equal 0, result['total']
  end
 
  test "GET to index with multiple sectors" do
    get :index, format: :json, sectors: 'agriculture,manufacturing',
      business_types: 'private-company', business_sizes: 'under-10',
      stages: 'start-up', locations: 'wales', support_types: 'loan'
    results = JSON.parse(response.body)['results']
    assert_equal "Urban Development Grant", results.first['title']
    assert_equal 2, results.first['priority']
    assert_equal ['loan'], results.first['support_types']
    assert_equal ['wales'], results.first['locations']
    assert_equal ['under-10'], results.first['business_sizes']
  end
  
  test "GET to index with no sectors param" do
    get :index, format: :json, business_types: 'charity', 
      business_sizes: 'up-to-249', stages: 'grow-and-sustain',
      locations: 'scotland', support_types: 'award'
    results = JSON.parse(response.body)['results']
    assert_equal "Business Mentoring", results.first['title']
    assert_equal 1, results.first['priority']
    assert_equal "EU Culture Programme", results.second['title']
    assert_equal 0, results.second['priority']
  end
  
  test "GET to index with multiple params for location, business type and size" do
    get :index, format: :json, business_types: 'charity,private-company',
      business_sizes: 'under-10,up-to-249', locations: 'scotland,wales'
    json = JSON.parse(response.body)
    results = json['results']
    assert_equal 4, json['total'].to_i
    assert_equal "Urban Development Grant", results.first['title']
    assert_equal "Business Mentoring", results.second['title']
    assert_equal "I have no sectors", results.third['title']
    assert_equal "EU Culture Programme", results.fourth['title']
  end
end
