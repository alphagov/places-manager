require 'test_helper'

class BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do
    @agriculture = BusinessSupportSector.create(name: "Agriculture", slug: "agriculture")
    @manufacturing = BusinessSupportSector.create(name: "Manufacturing", slug: "manufacturing")
    @loan = BusinessSupportType.create(name: "Loan", slug: "loan")
    @award = BusinessSupportType.create(name: "Award", slug: "award")
    @scotland = BusinessSupportNation.create(name: "Scotland", slug: "scotland")
    @wales = BusinessSupportNation.create(name: "Wales", slug: "wales")
    @private_company = BusinessSupportBusinessType.create(name: "Private Company", slug: "private-company")
    @charity = BusinessSupportBusinessType.create(name: "Charity", slug: "charity")
    @eu_culture_programme = BusinessSupportScheme.create(title: "EU Culture Programme",
      business_support_identifier: "eu-culture-programme")
    @urban_dev_grant = BusinessSupportScheme.create(title: "Urban Development Grant",
      business_support_identifier: "urban-development-grant")
    @start_up = BusinessSupportStage.create(name: "Start-up", slug: "start-up")
    @grow_sustain = BusinessSupportStage.create(name: "Grow and sustain", slug: "grow-and-sustain")
    @urban_dev_grant.business_support_sectors << @agriculture
    @urban_dev_grant.business_support_sectors << @manufacturing
    @urban_dev_grant.business_support_business_types << @private_company
    @urban_dev_grant.business_support_nations << @wales
    @urban_dev_grant.business_support_types << @loan
    @urban_dev_grant.business_support_stages << @start_up
    @eu_culture_programme.business_support_sectors << @agriculture
    @eu_culture_programme.business_support_business_types << @charity
    @eu_culture_programme.business_support_nations << @scotland
    @eu_culture_programme.business_support_types << @award
    @eu_culture_programme.business_support_stages << @grow_sustain
    @eu_culture_programme.save!
    @urban_dev_grant.save!
  end

  test "GET to index" do
    get :index, format: :json, sectors: ['agriculture', 'manufacturing'],
      business_types: ['private-company'], stages: ['start-up'], nations: ['wales'],
      types: ['loan']
    json = JSON.parse(response.body)
    assert_includes json.map{|h| h['title']}, "Urban Development Grant"

    get :index, format: :json, sectors: ['agriculture'],
      business_types: ['charity'], stages: ['grow-and-sustain'], nations: ['scotland'],
      types: ['award']
    json = JSON.parse(response.body)
    assert_includes json.map{|h| h['title']}, "EU Culture Programme"
  end
end
