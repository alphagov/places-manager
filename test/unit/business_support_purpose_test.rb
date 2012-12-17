require 'test_helper'

class BusinessSupportPurposeTest < ActiveSupport::TestCase
  setup do
    @purpose = FactoryGirl.create(:business_support_purpose, name: "Setting up your business")
  end
  
  test "should have and belong to many BusinessSupportSchemes" do
    3.times do |i| 
      @purpose.business_support_schemes << BusinessSupportScheme.new(
        title: "Foo scheme #{i + 1}", 
        business_support_identifier: "foo-scheme-#{i + 1}") 
    end
    assert_equal "Foo scheme 1", @purpose.business_support_schemes.first.title
    assert_equal "Foo scheme 3", @purpose.business_support_schemes.last.title 
  end
  
  test "should validates presence of name" do
    refute BusinessSupportPurpose.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_purpose = BusinessSupportPurpose.new(name: "Setting up your business")
    refute another_purpose.valid?, "should validate uniqueness of name."
  end
end
