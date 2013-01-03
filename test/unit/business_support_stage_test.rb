require 'test_helper'

class BusinessSupportStageTest < ActiveSupport::TestCase
  setup do
    @stage = FactoryGirl.create(:business_support_stage, name: "Finance")
  end
  
  test "should validates presence of name" do
    refute BusinessSupportStage.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportStage.new(name: "Finance")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
