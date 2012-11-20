require_relative '../../integration_test_helper'
require_relative '../../business_support_test_helper'

class BusinessSupportSchemeCreateEditTest < ActionDispatch::IntegrationTest

  setup do
    make_facets(:business_support_business_type, ["Global megacorp", "Private limited company", "Charity"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    @bs = FactoryGirl.create(:business_support_scheme,
                            title: "Wunderbiz Pro", business_support_identifier: "333",
                            business_types: [], locations: [@scotland.slug],
                            sectors: [@manufacturing.slug], stages: [], support_types: [])

  end

  test "create a business support scheme" do
    
    visit "/admin/business_support_schemes/new"

    fill_in "Title", :with => "Wunderbiz 2012 superfunding"

    select "Low", :from => "business_support_scheme[priority]"
    
    check "Charity"
    check "Global megacorp"
    check "England"
    check "Wales"
    check "Manufacturing"
    check "Healthcare"
    check "Agriculture"
    check "Grant"

    click_on "Create Business Support"

    bs = BusinessSupportScheme.last

    assert_equal "Wunderbiz 2012 superfunding", bs.title
    assert_equal 0, bs.priority
    assert_equal "334", bs.business_support_identifier
    assert_equal [@charity.slug, @global_megacorp.slug], bs.business_types
    assert_equal [@england.slug, @wales.slug], bs.locations
    assert_equal [@agriculture.slug, @healthcare.slug, @manufacturing.slug], bs.sectors
    assert_equal [@grant.slug], bs.support_types

    assert page.has_content? "Wunderbiz 2012 superfunding successfully created"

  end

  test "associating facets with a scheme" do
    
    visit "/admin/business_support_schemes/#{@bs._id.to_s}/edit"

    assert page.has_field?("Business support identifier", :with => "333")
    
    check "England"
    check "Wales"
    uncheck "Scotland"
    check "Agriculture"

    select "High", :from => "business_support_scheme[priority]"
    
    click_on "Update Business Support"

    @bs.reload

    assert page.has_content? "Wunderbiz Pro successfully updated"

    assert_equal [@england.slug, @wales.slug], @bs.locations
    assert_equal [@agriculture.slug, @manufacturing.slug], @bs.sectors
    assert_equal 2, @bs.priority
  end
end
