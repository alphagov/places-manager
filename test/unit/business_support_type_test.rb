require 'test_helper'

class BusinessSupportTypeTest < ActiveSupport::TestCase
  setup do
    @type = BusinessSupportType.create(name: "Private company")
  end
  
  test "should have and belong to many BusinessSupportSchemes" do
    3.times do |i| 
      @type.business_support_schemes << BusinessSupportScheme.new(
        title: "Foo scheme #{i + 1}", 
        business_support_identifier: "foo-scheme-#{i + 1}") 
    end
    assert_equal "Foo scheme 1", @type.business_support_schemes.first.title
    assert_equal "Foo scheme 3", @type.business_support_schemes.last.title 
  end
  
  test "should validates presence of name" do
    refute BusinessSupportType.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportType.new(name: "Private company")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
