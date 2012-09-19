require 'test_helper'

class BusinessSupportSectorTest < ActiveSupport::TestCase
  test "validates_uniqueness_of name" do
    assert_validates_uniqueness_of BusinessSupportRegion, :name
  end
  
  test "has_and_belongs_to_many BusinessSupportSchemes" do
    assert_association(BusinessSupportRegion, :references_and_referenced_in_many,
      :business_support_schemes, :index => true)      
  end
end
