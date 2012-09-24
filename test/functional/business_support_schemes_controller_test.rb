require 'test_helper'

class BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do
    agriculture = FactoryGirl.create(:business_support_sector, name: "Agriculture", slug: "agriculture")
    manufacturing = FactoryGirl.create(:business_support_sector, name: "Manufacturing", slug: "manufacturing")
    
    loan = FactoryGirl.create(:business_support_type, name: "Loan", slug: "loan")
    award = FactoryGirl.create(:business_support_type, name: "Award", slug: "award")
    scotland = FactoryGirl.create(:business_support_nation, name: "Scotland", slug: "scotland")
    wales = FactoryGirl.create(:business_support_nation, name: "Wales", slug: "wales")
    private_company = FactoryGirl.create(:business_support_business_type, name: "Private Company", slug: "private-company")
    charity = FactoryGirl.create(:business_support_business_type, name: "Charity", slug: "charity")
    eu_culture_programme = FactoryGirl.create(:business_support_scheme, title: "EU Culture Programme",
      business_support_identifier: "eu-culture-programme")
    urban_dev_grant = FactoryGirl.create(:business_support_scheme, title: "Urban Development Grant",
      business_support_identifier: "urban-development-grant")
    business_mentoring = FactoryGirl.create(:business_support_scheme, title: "Business Mentoring",
      business_support_identifier: "business-mentoring")
    start_up = FactoryGirl.create(:business_support_stage, name: "Start-up", slug: "start-up")
    grow_sustain = FactoryGirl.create(:business_support_stage, name: "Grow and sustain", slug: "grow-and-sustain")
    
    urban_dev_grant.business_support_sectors << agriculture
    urban_dev_grant.business_support_sectors << manufacturing
    urban_dev_grant.business_support_business_types << private_company
    urban_dev_grant.business_support_nations << wales
    urban_dev_grant.business_support_types << loan
    urban_dev_grant.business_support_stages << start_up
    
    eu_culture_programme.business_support_sectors << agriculture
    eu_culture_programme.business_support_business_types << charity
    eu_culture_programme.business_support_nations << scotland
    eu_culture_programme.business_support_types << award
    eu_culture_programme.business_support_stages << grow_sustain
    
    business_mentoring.business_support_business_types << charity
    business_mentoring.business_support_business_types << private_company
    business_mentoring.business_support_nations << scotland
    business_mentoring.business_support_nations << wales
    business_mentoring.business_support_types << award
    business_mentoring.business_support_types << loan
    business_mentoring.business_support_stages << grow_sustain
    
    eu_culture_programme.save!
    urban_dev_grant.save!
    business_mentoring.save!
  end

  test "GET to index no params" do
    get :index, format: :json
    json = JSON.parse(response.body)
    assert_equal 3, json['total'].to_i
  end

  test "GET to index with gibberish params" do
    get :index, format: :json, sectors: 'foo,bar'
    result = JSON.parse(response.body)
    assert_equal 'ok', result['_response_info']['status']
    assert_equal 0, result['total']  
  end
 
  test "GET to index with multiple sectors" do
    get :index, format: :json, sectors: 'agriculture,manufacturing',
      business_types: 'private-company', stages: 'start-up', nations: 'wales',
      types: 'loan'
    results = JSON.parse(response.body)['results']
    assert_equal "Urban Development Grant", results.first['title']

    get :index, format: :json, sectors: 'agriculture',
      business_types: 'charity', stages: 'grow-and-sustain', nations: 'scotland',
      types: 'award'
    results = JSON.parse(response.body)['results']
    assert_equal "EU Culture Programme", results.first['title']
  end
  
  test "GET to index with no sectors param" do
    get :index, format: :json, business_types: 'charity', 
      stages: 'grow-and-sustain', nations: 'scotland',
      types: 'award'
    results = JSON.parse(response.body)['results']
    assert_equal "Business Mentoring", results.first['title']
    assert_equal "EU Culture Programme", results.last['title']
  end
  
  test "GET to index with multiple params for nation and business type" do
    get :index, format: :json, business_types: 'charity,private-company',
      nations: 'scotland,wales', types: 'award,loan'
    json = JSON.parse(response.body)
    results = json['results']
    assert_equal 3, json['total'].to_i
    assert_equal "Business Mentoring", results.first['title']
    assert_equal "EU Culture Programme", results.second['title']
    assert_equal "Urban Development Grant", results.last['title']
  end
end
