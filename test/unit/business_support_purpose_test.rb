require 'test_helper'

class BusinessSupportPurposeTest < ActiveSupport::TestCase
  setup do
    @purpose = FactoryGirl.create(:business_support_purpose, name: "Setting up your business")
  end
  
  test "should validates presence of name" do
    refute BusinessSupportPurpose.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_purpose = BusinessSupportPurpose.new(name: "Setting up your business")
    refute another_purpose.valid?, "should validate uniqueness of name."
  end
end
