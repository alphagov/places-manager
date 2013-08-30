require_relative '../../integration_test_helper'
require_relative '../../business_support_test_helper'

class BusinessSupportSchemeCreateEditTest < ActionDispatch::IntegrationTest

  setup do
    
    Capybara.current_driver = Capybara.javascript_driver 
    
    make_facets(:business_support_business_type, ["Global megacorp", "Private limited company", "Charity"])
    make_facets(:business_support_business_size, ["Under 10", "Up to 249"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland", "London", "Yorkshire and the Humber"])
    make_facets(:business_support_purpose, ["Making the most of the Internet", "Exporting or finding overseas partners", 
                "Finding new customers and markets", "Energy efficiency and the environment"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    @bs = FactoryGirl.create(:business_support_scheme,
                            title: "Wunderbiz Pro", business_support_identifier: "333",
                            locations: [@scotland.slug], 
                            purposes: [@energy_efficiency_and_the_environment.slug],
                            sectors: [@manufacturing.slug])

  end

  test "create a business support scheme" do
    
    visit "/admin/business_support_schemes/new"

    fill_in "Title", :with => "Wunderbiz 2012 superfunding"

    select "Low", :from => "business_support_scheme[priority]"

    select "2013", :from => "business_support_scheme[start_date(1i)]"
    select "May", :from => "business_support_scheme[start_date(2i)]"
    select "3", :from => "business_support_scheme[start_date(3i)]"

    select "2013", :from => "business_support_scheme[end_date(1i)]"
    select "June", :from => "business_support_scheme[end_date(2i)]"
    select "3", :from => "business_support_scheme[end_date(3i)]"
    
    check "Charity"
    check "Global megacorp"
    check "Under 10"
    check "Up to 249"
    check "England"
    check "Wales"
    check "Manufacturing"
    check "Healthcare"
    check "Agriculture"
    check "Grant"
    check "Making the most of the Internet"
    check "Energy efficiency and the environment"

    click_on "Create Business Support"

    bs = BusinessSupportScheme.last

    assert_equal "Wunderbiz 2012 superfunding", bs.title
    assert_equal 0, bs.priority
    assert_equal "334", bs.business_support_identifier

    assert_equal Date.parse("2013/05/03"), bs.start_date
    assert_equal Date.parse("2013/06/03"), bs.end_date
    
    assert_equal [@charity.slug, @global_megacorp.slug], bs.business_types
    assert_equal [@under_10.slug, @up_to_249.slug], bs.business_sizes
    assert_equal [@england.slug, @london.slug, @wales.slug, @yorkshire_and_the_humber.slug], bs.locations
    assert_equal [@agriculture.slug, @healthcare.slug, @manufacturing.slug], bs.sectors
    assert_equal [@grant.slug], bs.support_types
    assert_equal [@energy_efficiency_and_the_environment.slug, @making_the_most_of_the_internet.slug], bs.purposes

    assert page.has_content? "Wunderbiz 2012 superfunding successfully created"

  end

  test "create a business support scheme with no start and end dates" do
    
    visit "/admin/business_support_schemes/new"

    fill_in "Title", :with => "Wunderbiz 2012 superfunding"

    select "Low", :from => "business_support_scheme[priority]"

    check "Charity"
    check "Global megacorp"
    check "Under 10"
    check "Up to 249"
    check "England"
    check "Wales"
    check "Manufacturing"
    check "Healthcare"
    check "Agriculture"
    check "Grant"
    check "Making the most of the Internet"
    check "Energy efficiency and the environment"

    click_on "Create Business Support"

    bs = BusinessSupportScheme.last

    assert_equal "Wunderbiz 2012 superfunding", bs.title
    assert_equal 0, bs.priority
    assert_equal "334", bs.business_support_identifier

    assert_nil bs.start_date
    assert_nil bs.end_date
    
    assert_equal [@charity.slug, @global_megacorp.slug], bs.business_types
    assert_equal [@under_10.slug, @up_to_249.slug], bs.business_sizes
    assert_equal [@england.slug, @london.slug, @wales.slug, @yorkshire_and_the_humber.slug], bs.locations
    assert_equal [@agriculture.slug, @healthcare.slug, @manufacturing.slug], bs.sectors
    assert_equal [@grant.slug], bs.support_types
    assert_equal [@energy_efficiency_and_the_environment.slug, @making_the_most_of_the_internet.slug], bs.purposes

    assert page.has_content? "Wunderbiz 2012 superfunding successfully created"

  end

  test "associating facets with a scheme" do
    
    visit "/admin/business_support_schemes/#{@bs._id.to_s}/edit"

    assert page.has_field?("Business support identifier", :with => "333")
    
    check "Wales"
    uncheck "Scotland"
    check "Agriculture"
    check "England"
    uncheck "Energy efficiency and the environment"
    check "Finding new customers and markets"

    select "High", :from => "business_support_scheme[priority]"
    
    click_on "Update Business Support"

    @bs.reload

    assert page.has_content? "Wunderbiz Pro successfully updated"

    assert_equal [@england.slug, @london.slug, @wales.slug, @yorkshire_and_the_humber.slug], @bs.locations
    assert_equal [@agriculture.slug, @manufacturing.slug], @bs.sectors
    assert_equal [@finding_new_customers_and_markets.slug], @bs.purposes
    assert_equal 2, @bs.priority

    visit "/admin/business_support_schemes/#{@bs._id.to_s}/edit"

    assert page.has_checked_field?("Wales")
    assert page.has_checked_field?("England")
    assert page.has_checked_field?("Agriculture")
    assert page.has_checked_field?("Finding new customers and markets")
    refute page.has_checked_field?("Scotland")
    refute page.has_checked_field?("Energy efficiency and the environment")
  end
end
