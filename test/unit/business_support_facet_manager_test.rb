require 'business_support_test_helper'
require 'business_support_facet_manager'

class BusinessSupportFacetManagerTest < ActiveSupport::TestCase

  include BusinessSupportTestHelper
  
  setup do
    make_facets(:business_support_business_type, ["Global megacorp", "Private company", "Charity"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland", "London", "South East", "Yorkshire and the Humber"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    @superbiz = FactoryGirl.create(:business_support_scheme, title: "Super biz support",
                                   business_support_identifier: "111", priority: 1)
    @wunderbiz = FactoryGirl.create(:business_support_scheme, title: "Wunder biz support",
                                   business_support_identifier: "112", priority: 1)
    @megabiz = FactoryGirl.create(:business_support_scheme, title: "Mega biz support",
                                   business_support_identifier: "113", priority: 1)

    @superbiz.business_support_business_types = [@global_megacorp, @private_company]
    @superbiz.business_support_locations = [@england, @wales]
    @superbiz.save!

    @wunderbiz.business_support_sectors = [@agriculture, @healthcare]
    @wunderbiz.business_support_stages = [@pre_startup, @startup]
    @wunderbiz.business_support_types = [@award, @loan]
    @wunderbiz.save!

  end
 
  test "populate empty collections" do
    silence_stream(STDOUT) do
      BusinessSupportFacetManager.populate_empty_collections
    end

    @superbiz.reload
    @wunderbiz.reload
    @megabiz.reload

    assert_equal [@global_megacorp, @private_company], @superbiz.business_support_business_types
    assert_equal [@global_megacorp, @private_company, @charity], @wunderbiz.business_support_business_types
    assert_equal [@global_megacorp, @private_company, @charity], @megabiz.business_support_business_types

    assert_equal [@england, @wales], @superbiz.business_support_locations
    assert_equal [@england, @scotland, @wales, @northern_ireland, @london, @south_east, @yorkshire_and_the_humber], 
      @wunderbiz.business_support_locations
    assert_equal [@england, @scotland, @wales, @northern_ireland, @london, @south_east, @yorkshire_and_the_humber], 
      @megabiz.business_support_locations

    assert_equal [@agriculture, @healthcare], @wunderbiz.business_support_sectors
    assert_equal [@agriculture, @healthcare, @manufacturing], @superbiz.business_support_sectors
    assert_equal [@agriculture, @healthcare, @manufacturing], @megabiz.business_support_sectors

    assert_equal [@pre_startup, @startup], @wunderbiz.business_support_stages
    assert_equal [@pre_startup, @startup, @grow_and_sustain], @superbiz.business_support_stages

    assert_equal [@award, @loan, @grant], @superbiz.business_support_types
    assert_equal [@award, @loan], @wunderbiz.business_support_types
    assert_equal [@award, @loan, @grant], @megabiz.business_support_types
  end

  test "associate_english_regions" do
    scheme1 = FactoryGirl.create(:business_support_scheme, title: "scheme1",
                                  business_support_identifier: "345", priority: 1)
    scheme2 = FactoryGirl.create(:business_support_scheme, title: "scheme2",
                                  business_support_identifier: "123", priority: 1)
    scheme3 = FactoryGirl.create(:business_support_scheme, title: "scheme3",
                                  business_support_identifier: "432", priority: 1)

    [scheme1, scheme2, scheme3].each do |scheme|
      scheme.business_support_locations = [@england]
      scheme.save!
    end

    BusinessSupportFacetManager.stubs(:english_regional_data).returns([
      { "id" => "345", "region" => "London" }, 
      { "id" => "123", "region" => "Yorkshire and the Humber" },
      { "id" => "345", "region" => "South East" },
      { "id" => "999", "region" => "South East" }
    ])

    silence_stream(STDOUT) do
      BusinessSupportFacetManager.associate_english_regions
    end

    scheme1.reload
    scheme2.reload
    scheme3.reload
    @superbiz.reload

    assert_equal [@london, @south_east], scheme1.business_support_locations
    assert_equal [@yorkshire_and_the_humber], scheme2.business_support_locations
    assert_equal [@england, @london, @south_east, @yorkshire_and_the_humber], scheme3.business_support_locations
    assert_equal [@england, @wales, @london, @south_east, @yorkshire_and_the_humber], @superbiz.business_support_locations

  end

  test "associate_purpose_facets" do
    scheme1 = FactoryGirl.create(:business_support_scheme, title: "scheme1",
                                  business_support_identifier: "345", priority: 1)
    scheme2 = FactoryGirl.create(:business_support_scheme, title: "scheme2",
                                  business_support_identifier: "123", priority: 1)
    scheme3 = FactoryGirl.create(:business_support_scheme, title: "scheme3",
                                  business_support_identifier: "432", priority: 1)
    
    make_facets(:business_support_purpose, ["Making the most of the Internet", "Exporting or finding overseas partners", 
                "Finding new customers and markets", "Energy efficiency and the environment"])


    BusinessSupportFacetManager.stubs(:purpose_facet_data).returns([
      { "id" => "14", "name" => "Making the most of the Internet" }, 
      { "id" => "5",  "name" => "Exporting or finding overseas partners" },
      { "id" => "18", "name" => "Finding new customers and markets" },
      { "id" => "12", "name" => "Energy efficiency and the environment" }
    ])

    BusinessSupportFacetManager.stubs(:purposes_join_data).returns([
      { "bsf_scheme_id" => "345", "bsf_support_purpose_id" => "14" },
      { "bsf_scheme_id" => "345", "bsf_support_purpose_id" => "5" },
      { "bsf_scheme_id" => "123", "bsf_support_purpose_id" => "5" },
      { "bsf_scheme_id" => "123", "bsf_support_purpose_id" => "18" },
      { "bsf_scheme_id" => "123", "bsf_support_purpose_id" => "12" }
    ])

    silence_stream(STDOUT) do
      BusinessSupportFacetManager.associate_purpose_facets
    end

    scheme1.reload
    scheme2.reload
    scheme3.reload

    assert_equal [@making_the_most_of_the_internet, @exporting_or_finding_overseas_partners], scheme1.business_support_purposes
    assert_equal [@exporting_or_finding_overseas_partners, @finding_new_customers_and_markets,
                  @energy_efficiency_and_the_environment], scheme2.business_support_purposes
    assert_equal [@making_the_most_of_the_internet, @exporting_or_finding_overseas_partners, 
                  @finding_new_customers_and_markets, @energy_efficiency_and_the_environment], scheme3.business_support_purposes

  end

end
