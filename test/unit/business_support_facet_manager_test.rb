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
                                   business_support_identifier: "111", priority: 1,
                                   business_types: [], locations: [], sectors: [], stages: [], support_types: [])
    @wunderbiz = FactoryGirl.create(:business_support_scheme, title: "Wunder biz support",
                                   business_support_identifier: "112", priority: 1,
                                   business_types: [], locations: [], sectors: [], stages: [], support_types: [])
    @megabiz = FactoryGirl.create(:business_support_scheme, title: "Mega biz support",
                                   business_support_identifier: "113", priority: 1,
                                   business_types: [], locations: [], sectors: [], stages: [], support_types: [])

    @superbiz.business_types = [@global_megacorp.slug, @private_company.slug]
    @superbiz.locations = [@england.slug, @wales.slug]
    @superbiz.save!

    @wunderbiz.sectors = [@agriculture.slug, @healthcare.slug]
    @wunderbiz.stages = [@pre_startup.slug, @startup.slug]
    @wunderbiz.support_types = [@award.slug, @loan.slug]
    @wunderbiz.save!

  end
 
  test "populate empty collections" do
    silence_stream(STDOUT) do
      BusinessSupportFacetManager.populate_empty_collections
    end

    @superbiz.reload
    @wunderbiz.reload
    @megabiz.reload

    assert_equal [@global_megacorp.slug, @private_company.slug], @superbiz.business_types
    assert_equal [@charity.slug, @global_megacorp.slug, @private_company.slug], @wunderbiz.business_types
    assert_equal [@charity.slug, @global_megacorp.slug, @private_company.slug], @megabiz.business_types

    assert_equal [@england.slug, @london.slug, @northern_ireland.slug, @scotland.slug,
      @south_east.slug, @wales.slug, @yorkshire_and_the_humber.slug], @wunderbiz.locations
    
    assert_equal [@england.slug, @london.slug, @northern_ireland.slug, @scotland.slug,
      @south_east.slug, @wales.slug, @yorkshire_and_the_humber.slug], @megabiz.locations

    assert_equal [@england.slug, @wales.slug], @superbiz.locations

    assert_equal [@agriculture.slug, @healthcare.slug], @wunderbiz.sectors
    assert_equal [@agriculture.slug, @healthcare.slug, @manufacturing.slug], @superbiz.sectors
    assert_equal [@agriculture.slug, @healthcare.slug, @manufacturing.slug], @megabiz.sectors

    assert_equal [@pre_startup.slug, @startup.slug], @wunderbiz.stages
    assert_equal [@grow_and_sustain.slug, @pre_startup.slug, @startup.slug], @superbiz.stages

    assert_equal [@award.slug, @grant.slug, @loan.slug], @superbiz.support_types
    assert_equal [@award.slug, @loan.slug], @wunderbiz.support_types
    assert_equal [@award.slug, @grant.slug, @loan.slug], @megabiz.support_types
  end

  test "facet ids to slugs" do

    @ultrabiz = FactoryGirl.create(:business_support_scheme, title: "Ultra biz support",
                                   business_support_identifier: "10101", priority: 2,
                                   #business_types: [], locations: [], sectors: [], stages: [], support_types: [],
                                   business_support_business_type_ids: [@private_company._id],
                                   business_support_location_ids: [@england._id, @scotland._id],
                                   business_support_sector_ids: [@agriculture._id, @healthcare._id],
                                   business_support_stage_ids: [@startup._id],
                                   business_support_type_ids: [@award._id, @grant._id])

    silence_stream(STDOUT) do
      BusinessSupportFacetManager.facet_ids_to_slugs
    end

    @ultrabiz.reload

    assert @ultrabiz.business_support_business_type_ids.empty?
    assert @ultrabiz.business_support_location_ids.empty?
    assert @ultrabiz.business_support_sector_ids.empty?
    assert @ultrabiz.business_support_stage_ids.empty?
    assert @ultrabiz.business_support_type_ids.empty?

    assert_equal [@private_company.slug], @ultrabiz.business_types
    assert_equal [@england.slug, @scotland.slug], @ultrabiz.locations
    assert_equal [@agriculture.slug, @healthcare.slug], @ultrabiz.sectors
    assert_equal [@startup.slug], @ultrabiz.stages
    assert_equal [@award.slug, @grant.slug], @ultrabiz.support_types
  end

  test "clear facet relations" do
    @superbiz.business_support_sectors << @agriculture
    @superbiz.save

    silence_stream(STDOUT) do
      BusinessSupportFacetManager.clear_facet_relations
    end

    @agriculture.reload

    assert @agriculture.business_support_scheme_ids.empty?

  end
  
  test "associate_english_regions" do
    scheme1 = FactoryGirl.create(:business_support_scheme, title: "scheme1",
                                  business_support_identifier: "345", priority: 1,
                                  business_types: [], locations: [], sectors: [], stages: [], support_types: [])
    scheme2 = FactoryGirl.create(:business_support_scheme, title: "scheme2",
                                  business_support_identifier: "123", priority: 1,
                                  business_types: [], locations: [], sectors: [], stages: [], support_types: [])
    scheme3 = FactoryGirl.create(:business_support_scheme, title: "scheme3",
                                  business_support_identifier: "432", priority: 1,
                                  business_types: [], locations: [], sectors: [], stages: [], support_types: [])

    [scheme1, scheme2, scheme3].each do |scheme|
      scheme.locations = [@england.slug]
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

    assert_equal [@london.slug, @south_east.slug], scheme1.locations
    assert_equal [@yorkshire_and_the_humber.slug], scheme2.locations
    assert_equal [@england.slug, @london.slug, @south_east.slug, @yorkshire_and_the_humber.slug], scheme3.locations
    assert_equal [@england.slug, @wales.slug, @london.slug, @south_east.slug, @yorkshire_and_the_humber.slug], @superbiz.locations

  end

end
