require 'test_helper'

class BusinessSupportTypeTest < ActiveSupport::TestCase
  setup do
    @type = BusinessSupportType.create(name: "Loan", slug: "loan")
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
