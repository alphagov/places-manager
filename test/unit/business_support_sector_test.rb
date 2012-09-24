require 'test_helper'

class BusinessSupportSectorTest < ActiveSupport::TestCase
  setup do
    @sector = BusinessSupportSector.create(name: "Finance")
  end
  
  test "should have and belong to many BusinessSupportSchemes" do
    3.times do |i| 
      @sector.business_support_schemes << BusinessSupportScheme.new(
        title: "Foo scheme #{i + 1}", 
        business_support_identifier: "foo-scheme-#{i + 1}") 
    end
    assert_equal "Foo scheme 1", @sector.business_support_schemes.first.title
    assert_equal "Foo scheme 3", @sector.business_support_schemes.last.title 
  end
  
  test "should validates presence of name" do
    refute BusinessSupportSector.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportSector.new(name: "Finance")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
