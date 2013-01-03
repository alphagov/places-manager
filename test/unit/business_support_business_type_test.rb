require 'test_helper'

class BusinessSupportBusinessTypeTest < ActiveSupport::TestCase
  setup do
    @charity = FactoryGirl.create(:business_support_business_type, name: "Charity", slug: "charity")
  end
  
  test "should validate presence of name" do
    refute BusinessSupportBusinessType.new(slug: "charity").valid?
  end
  
  test "should validate uniqueness of name" do
    another_type = BusinessSupportBusinessType.new(name: "Charity")
    refute another_type.valid?, "should validate uniqueness of name."
  end

  test "should validate presence of slug" do
    refute BusinessSupportBusinessType.new(name: "Charity").valid?
  end
  
  test "should validate uniqueness of slug" do
    another_type = BusinessSupportBusinessType.new(name: "Charity", slug: "charity")
    refute another_type.valid?, "should validate uniqueness of slug."
  end
end
