require 'test_helper'

class BusinessSupportSchemesHelperTest < ActiveSupport::TestCase

  include Admin::BusinessSupportSchemesHelper
  
  setup do
    @scheme = FactoryGirl.create(:business_support_scheme, 
      title: "Tourism support grant. West Dunbartonshire", 
      business_support_identifier: "tourism-support-grant-west-dunbartonshire",
      priority: 1)
  end

  test "priority_options" do
    assert_equal [["Low",0],["Normal",1],["High",2]], priority_options
  end

  test "priority_label" do
    assert_equal "Low", priority_label(0)
    assert_equal "Normal", priority_label(1)
    assert_equal "High", priority_label(2)
  end

end
