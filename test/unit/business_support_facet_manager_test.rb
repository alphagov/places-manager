require 'business_support_test_helper'
require 'business_support_facet_manager'

class BusinessSupportFacetManagerTest < ActiveSupport::TestCase

  include BusinessSupportTestHelper
  
  setup do
    make_facets(:business_support_business_type, ["Global megacorp", "Private company", "Charity"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland"])
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
    assert_equal [@england, @scotland, @wales, @northern_ireland], @wunderbiz.business_support_locations
    assert_equal [@england, @scotland, @wales, @northern_ireland], @megabiz.business_support_locations

    assert_equal [@agriculture, @healthcare], @wunderbiz.business_support_sectors
    assert_equal [@agriculture, @healthcare, @manufacturing], @superbiz.business_support_sectors
    assert_equal [@agriculture, @healthcare, @manufacturing], @megabiz.business_support_sectors

    assert_equal [@pre_startup, @startup], @wunderbiz.business_support_stages
    assert_equal [@pre_startup, @startup, @grow_and_sustain], @superbiz.business_support_stages

    assert_equal [@award, @loan, @grant], @superbiz.business_support_types
    assert_equal [@award, @loan], @wunderbiz.business_support_types
    assert_equal [@award, @loan, @grant], @megabiz.business_support_types
  end

end
