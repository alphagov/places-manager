require_relative '../../integration_test_helper'

class BusinessSupportSchemeEditTest < ActionDispatch::IntegrationTest

  def make_facets(facet_type, names)
    names.each do |name|
      slug = name.parameterize
      instance_variable_set(:"@#{slug.underscore}", FactoryGirl.create(facet_type, name: name, slug: slug))
    end
  end

  setup do
    @controller = BusinessSupportSchemesController
    
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])

    @bs = FactoryGirl.create(:business_support_scheme,
                            title: "Wunderbiz Pro", business_support_identifier: "333",
                            business_support_location_ids: [@scotland._id],
                            business_support_sector_ids: [@manufacturing._id])
    
    GDS::SSO.test_user = FactoryGirl.create(:user)
  end

  test "associating facets with a scheme" do
    visit "/admin/business_support_schemes/#{@bs._id.to_s}/edit"

    check "England"
    check "Wales"
    uncheck "Scotland"
    check "Agriculture"
    
    click_on "Update Business Support"

    @bs.reload

    assert_equal [@england, @wales], @bs.business_support_locations
    assert_equal [@agriculture, @manufacturing], @bs.business_support_sectors
  end
end
