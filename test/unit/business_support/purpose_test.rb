require 'test_helper'

class BusinessSupport::PurposeTest < ActiveSupport::TestCase
  setup do
    @purpose = FactoryGirl.create(:business_support_purpose, name: "Setting up your business")
  end
  
  test "should validates presence of name" do
    refute BusinessSupport::Purpose.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_purpose = BusinessSupport::Purpose.new(name: "Setting up your business")
    refute another_purpose.valid?, "should validate uniqueness of name."
  end
end
