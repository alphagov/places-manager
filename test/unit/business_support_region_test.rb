require 'test_helper'

class BusinessSupportRegionTest < ActiveSupport::TestCase
  test "has and belongs to many BusinessSupportSchemes" do
    assert_association(BusinessSupportRegion, :references_and_referenced_in_many, 
      :business_support_schemes, :index => true)
  end
  
  test "validates_uniqueness_of name" do
    assert_validates_uniqueness_of BusinessSupportRegion, :name
  end
end
