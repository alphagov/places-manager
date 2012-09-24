require 'test_helper'

class BusinessSupportNationTest < ActiveSupport::TestCase
  setup do
    @region = FactoryGirl.create(:business_support_nation, name: "Ecclefechan")
  end
  
  test "should have and belong to many BusinessSupportSchemes" do
    3.times do |i| 
      @region.business_support_schemes << BusinessSupportScheme.new(
        title: "Foo scheme #{i + 1}", 
        business_support_identifier: "foo-scheme-#{i + 1}") 
    end
    assert_equal "Foo scheme 1", @region.business_support_schemes.first.title
    assert_equal "Foo scheme 3", @region.business_support_schemes.last.title 
  end
  
  test "should validates presence of name" do
    refute BusinessSupportNation.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportNation.new(name: "Ecclefechan")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
