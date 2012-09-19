require 'test_helper'

class BusinessSupportStageTest < ActiveSupport::TestCase
  test "validates_uniqueness_of name" do
    assert_validates_uniqueness_of BusinessSupportStage, :name
  end
  
  test "has_and_belongs_to_many BusinessSupportSchemes" do
    assert_association(BusinessSupportStage, :references_and_referenced_in_many,
      :business_support_schemes, :index => true)      
  end
end
