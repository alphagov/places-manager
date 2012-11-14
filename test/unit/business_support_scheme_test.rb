require 'test_helper'

class BusinessSupportSchemeTest < ActiveSupport::TestCase

  setup do
    @scheme = FactoryGirl.create(:business_support_scheme, 
      title: "Tourism support grant. West Dunbartonshire", 
      business_support_identifier: "99",
      priority: 1)
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
      business_support_identifier: "99")
    refute another_scheme.valid?, "should validate uniqueness of business_support_identifier."
  end

  test "should validate the priority value" do
    scheme = BusinessSupportScheme.new(title: "Foo scheme", business_support_identifier: "1001", priority: nil)
    refute scheme.valid?, "Priority should not be nil"
    scheme.priority = 3
    refute scheme.valid?, "Priority should be 0, 1 or 2"
    scheme.priority = 2
    assert scheme.valid?
  end

  test "should have and belong to many BusinessSupportBusinessTypes" do
    @scheme.business_support_business_types << BusinessSupportBusinessType.new(name: "Charity")
    @scheme.business_support_business_types << BusinessSupportBusinessType.new(name: "Private company")
    assert_equal "Charity", @scheme.business_support_business_types.first.name
    assert_equal "Private company", @scheme.business_support_business_types.last.name 
  end
 
  test "should have and belong to many BusinessSupportNations" do
    @scheme.business_support_locations << BusinessSupportLocation.new(name: "Auchtermuchty")
    @scheme.business_support_locations << BusinessSupportLocation.new(name: "Ecclefechan")
    @scheme.business_support_locations << BusinessSupportLocation.new(name: "London")
    assert_equal "Auchtermuchty", @scheme.business_support_locations.first.name
    assert_equal "London", @scheme.business_support_locations.last.name 
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
    @scheme.business_support_types << BusinessSupportType.new(name: "Award")
    @scheme.business_support_types << BusinessSupportType.new(name: "Loan")
    assert_equal "Award", @scheme.business_support_types.first.name
    assert_equal "Loan", @scheme.business_support_types.last.name 
  end
   
  test "should be scoped by relations and ordered by priority then title" do
    @another_scheme = FactoryGirl.create(:business_support_scheme, title: "Wunderscheme", 
                                         business_support_identifier: "123",
                                         priority: 2)
    @start_up = FactoryGirl.create(:business_support_stage, name: "Start up", slug: "start-up")
    @scheme.business_support_stages << @start_up
    @scheme.save!
    @another_scheme.business_support_stages << @start_up
    @another_scheme.save!
    assert_equal @another_scheme, BusinessSupportScheme.for_relations(stages: "start-up").first
    assert_equal @scheme, BusinessSupportScheme.for_relations(stages: "start-up").second
    assert_equal @another_scheme, BusinessSupportScheme.for_relations(stages: "start-up", sectors: "manufacturing").first
    @manufacturing = FactoryGirl.create(:business_support_sector, name: "Manufacturing", slug: "manufacturing")
    @scheme.business_support_sectors << @manufacturing
    @another_scheme.business_support_sectors << @manufacturing
    @scheme.save!
    @another_scheme.save!
    assert_equal 0, BusinessSupportScheme.for_relations(stages: "start-up", sectors: "Agriculture").count
    assert_equal @another_scheme, BusinessSupportScheme.for_relations(stages: "start-up", sectors: "agriculture,manufacturing").first
    assert_equal @scheme, BusinessSupportScheme.for_relations(stages: "start-up", sectors: "agriculture,manufacturing").second
  end

  test "class method next_identifier" do
    assert_equal 100, BusinessSupportScheme.next_identifier
  end
end
