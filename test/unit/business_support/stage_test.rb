require 'test_helper'

class BusinessSupport::StageTest < ActiveSupport::TestCase
  setup do
    @stage = FactoryGirl.create(:business_support_stage, name: "Finance")
  end
  
  test "should validates presence of name" do
    refute BusinessSupport::Stage.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupport::Stage.new(name: "Finance")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
