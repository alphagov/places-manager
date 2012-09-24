require 'test_helper'

class BusinessSupportBusinessTypeTest < ActiveSupport::TestCase
  setup do
    @charity = BusinessSupportBusinessType.create(name: "Charity", slug: "charity")
  end
  
  test "should have and belong to many BusinessSupportSchemes" do
    3.times do |i| 
      @charity.business_support_schemes << BusinessSupportScheme.new(
        title: "Some scheme #{i + 1}", 
        business_support_identifier: "some-scheme-#{i + 1}") 
    end
    assert_equal "Some scheme 1", @charity.business_support_schemes.first.title
    assert_equal "Some scheme 3", @charity.business_support_schemes.last.title 
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
