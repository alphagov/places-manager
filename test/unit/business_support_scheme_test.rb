require 'test_helper'

class BusinessSupportSchemeTest < ActiveSupport::TestCase

  setup do
    @scheme = BusinessSupportScheme.create( 
      title: "Tourism support grant. West Dunbartonshire", 
      business_support_identifier: "tourism-support-grant-west-dunbartonshire")
  end

  test "should validate presence of title" do
    scheme = BusinessSupportScheme.new(business_support_identifier: "foo-scheme")
    refute scheme.valid?, "should validate presence of title."
    scheme.title = "Foo scheme"
    assert scheme.valid?, "should validate presence of title."
  end
  
  test "should validate presence of business_support_identifier" do
    scheme = BusinessSupportScheme.new(title: "Foo scheme")
    refute scheme.valid?, "should validate presence of business_support_identifier."
    scheme.business_support_identifier = "foo-scheme"
    assert scheme.valid?, "should validate presence of business_support_identifier."
  end
  
  test "should validate uniqueness of title" do
    another_scheme = BusinessSupportScheme.new(
      title: "Tourism support grant. West Dunbartonshire", 
      business_support_identifier: "foo")
    refute another_scheme.valid?, "should validate uniqueness of title."
  end
  
  test "should validate uniqueness of business_support_identifier" do
    another_scheme = BusinessSupportScheme.new(title: "Foo", 
      business_support_identifier: "tourism-support-grant-west-dunbartonshire")
    refute another_scheme.valid?, "should validate uniqueness of business_support_identifier."
  end
  
  test "should have and belong to many BusinessSupportRegions" do
    @scheme.business_support_regions << BusinessSupportRegion.new(name: "Auchtermuchty")
    @scheme.business_support_regions << BusinessSupportRegion.new(name: "Ecclefechan")
    @scheme.business_support_regions << BusinessSupportRegion.new(name: "London")
    assert_equal "Auchtermuchty", @scheme.business_support_regions.first.name
    assert_equal "London", @scheme.business_support_regions.last.name 
  end
  
  test "should have and belong to many BusinessSupportSectors" do
    @scheme.business_support_sectors << BusinessSupportSector.new(name: "Finance")
    @scheme.business_support_sectors << BusinessSupportSector.new(name: "Law")
    @scheme.business_support_sectors << BusinessSupportSector.new(name: "Media")
    assert_equal "Finance", @scheme.business_support_sectors.first.name
    assert_equal "Media", @scheme.business_support_sectors.last.name 
  end
  
  test "should have and belong to many BusinessSupportStages" do
    @scheme.business_support_stages << BusinessSupportStage.new(name: "Start-up")
    @scheme.business_support_stages << BusinessSupportStage.new(name: "Grow and sustain")
    assert_equal "Start-up", @scheme.business_support_stages.first.name
    assert_equal "Grow and sustain", @scheme.business_support_stages.last.name 
  end
  
  test "should have and belong to many BusinessSupportTypes" do
    @scheme.business_support_types << BusinessSupportType.new(name: "Private company")
    @scheme.business_support_types << BusinessSupportType.new(name: "Charity")
    assert_equal "Private company", @scheme.business_support_types.first.name
    assert_equal "Charity", @scheme.business_support_types.last.name 
  end
    
end
