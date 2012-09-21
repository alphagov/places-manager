require 'test_helper'
require 'business_support_data_importer'

class BusinessSupportDataImporterTest < ActiveSupport::TestCase
 
  setup do
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_schemes").returns([
        {'id' => 1, 'title' => "Get rich quick"},
        {'id' => 2, 'title' => "Get rich quick"},
        {'id' => 99, 'title' => "Enable the enterprise"},
        {'id' => 999, 'title' => "Hedge funds for dummies"}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_business_types").returns([
        {'id' => 321, 'name' => "Private company"},
        {'id' => 654, 'name' => "Charity"},
        {'id' => 987, 'name' => "Sole trader"}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_schemes_business_types").returns([
        {'bsf_business_type_id' => 321, 'bsf_scheme_id' => 1},
        {'bsf_business_type_id' => 321, 'bsf_scheme_id' => 999},
        {'bsf_business_type_id' => 987, 'bsf_scheme_id' => 999},
        {'bsf_business_type_id' => 654, 'bsf_scheme_id' => 99}
      ])      
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_nations").returns([
        {'id' => 1, 'name' => "London"},
        {'id' => 2, 'name' => "Auchtermuchty"},
        {'id' => 3, 'name' => "Ecclefechan"}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_schemes_nations").returns([
        {'bsf_nation_id' => 1, 'bsf_scheme_id' => 99},
        {'bsf_nation_id' => 2, 'bsf_scheme_id' => 99},
        {'bsf_nation_id' => 2, 'bsf_scheme_id' => 999},
        {'bsf_nation_id' => 3, 'bsf_scheme_id' => 1}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_stages").returns([
        {'id' => 1, 'name' => "Start-up"},
        {'id' => 2, 'name' => "Grow and sustain"},
        {'id' => 3, 'name' => "Crash and burn"}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_schemes_stages").returns([
        {'bsf_stage_id' => 1, 'bsf_scheme_id' => 1},
        {'bsf_stage_id' => 2, 'bsf_scheme_id' => 999},
        {'bsf_stage_id' => 2, 'bsf_scheme_id' => 1},
        {'bsf_stage_id' => 3, 'bsf_scheme_id' => 99}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_sectors").returns([
        {'id' => 100, 'name' => "Finance"},
        {'id' => 150, 'name' => "Law"},
        {'id' => 200, 'name' => "Media"}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_schemes_sectors").returns([
        {'bsf_sector_id' => 100, 'bsf_scheme_id' => 1},
        {'bsf_sector_id' => 200, 'bsf_scheme_id' => 999},
        {'bsf_sector_id' => 150, 'bsf_scheme_id' => 999}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_types").returns([
        {'id' => 321, 'name' => "Award"},
        {'id' => 654, 'name' => "Grant"},
        {'id' => 987, 'name' => "Loan"}
      ])
    BusinessSupportDataImporter.any_instance.stubs(:csv_data).with(
      "data", "bsf_schemes_types").returns([
        {'bsf_type_id' => 321, 'bsf_scheme_id' => 1},
        {'bsf_type_id' => 321, 'bsf_scheme_id' => 999},
        {'bsf_type_id' => 987, 'bsf_scheme_id' => 999},
        {'bsf_type_id' => 654, 'bsf_scheme_id' => 99}
      ])  
    
    silence_stream(STDOUT) do
      BusinessSupportDataImporter.run("data")
    end
    @schemes = BusinessSupportScheme.all
  end
      
  test "Business support schemes are created" do
    assert_equal 1, BusinessSupportScheme.where(:title => 'Get rich quick').size
    assert_equal "get-rich-quick", @schemes.first.business_support_identifier
    assert_equal "Enable the enterprise", @schemes.second.title
    assert_equal "hedge-funds-for-dummies", @schemes.last.business_support_identifier
    
  end

  test "BusinessSupportSchemes have and belong to many BusinessSupportBusinessTypes" do
    charity = BusinessSupportBusinessType.where(name: "Charity").first
    
    assert_equal @schemes.second, charity.business_support_schemes.first
    assert_equal "Private company", @schemes.first.business_support_business_types.first.name
    assert_equal "Private company", @schemes.last.business_support_business_types.first.name
    assert_equal "Sole trader", @schemes.last.business_support_business_types.second.name
  end

  
  test "BusinessSupportSchemes have and belong to many BusinessSupportNations" do
    ecclefechan = BusinessSupportNation.where(name: "Ecclefechan").first
    
    assert_equal "Get rich quick", ecclefechan.business_support_schemes.first.title
    assert_equal 1, @schemes.first.business_support_nations.size
    assert_equal "Ecclefechan", @schemes.first.business_support_nations.first.name
    assert_equal 2, @schemes.second.business_support_nations.size
    assert_equal "London", @schemes.second.business_support_nations.first.name
    assert_equal "Auchtermuchty", @schemes.second.business_support_nations.last.name
  end
  
  test "BusinessSupportSchemes have and belong to many BusinessSupportSectors" do
    media_sector = BusinessSupportSector.where(name: "Media").first
    
    assert_equal @schemes.last, media_sector.business_support_schemes.first
    assert @schemes.second.business_support_sectors.empty?, "No associations should exist"
    assert_equal "Finance", @schemes.first.business_support_sectors.first.name
    assert_equal "Media", @schemes.last.business_support_sectors.first.name
    assert_equal "Law", @schemes.last.business_support_sectors.last.name
  end
  
  test "BusinessSupportSchemes have and belong to many BusinessSupportStages" do
    crash_and_burn = BusinessSupportStage.where(name: "Crash and burn").first
    
    assert_equal @schemes.second, crash_and_burn.business_support_schemes.first  
    assert_equal "Start-up", @schemes.first.business_support_stages.first.name
    assert_equal "Crash and burn", @schemes.second.business_support_stages.first.name
    assert_equal "Grow and sustain", @schemes.last.business_support_stages.last.name
  end
  
  test "BusinessSupportSchemes have and belong to many BusinessSupportTypes" do
    award = BusinessSupportType.where(name: "Award").first
    
    assert_equal @schemes.first, award.business_support_schemes.first
    assert_equal "Award", @schemes.first.business_support_types.first.name
    assert_equal "Award", @schemes.last.business_support_types.first.name
    assert_equal "Loan", @schemes.last.business_support_types.second.name
  end
  
end
