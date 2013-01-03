require 'test_helper'

class BusinessSupportTypeTest < ActiveSupport::TestCase
  setup do
    @type = FactoryGirl.create(:business_support_type, name: "Loan", slug: "loan")
  end
  
  test "should validates presence of name" do
    refute BusinessSupportType.new(slug: "short-term-loan").valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportType.new(name: "Loan", slug: "short-term-loan")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end

  test "should validates presence of slug" do
    refute BusinessSupportType.new(name: "Loan").valid?
  end
  
  test "should validate uniqueness of slug" do
    another_scheme = BusinessSupportType.new(name: "Loan", slug: "loan")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
