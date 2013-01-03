require 'test_helper'

class BusinessSupportLocationTest < ActiveSupport::TestCase
  setup do
    @region = FactoryGirl.create(:business_support_location, name: "Ecclefechan")
  end
  
  test "should validates presence of name" do
    refute BusinessSupportLocation.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportLocation.new(name: "Ecclefechan")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
