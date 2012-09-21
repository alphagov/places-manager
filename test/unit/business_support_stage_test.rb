require 'test_helper'

class BusinessSupportStageTest < ActiveSupport::TestCase
  setup do
    @stage = BusinessSupportStage.create(name: "Finance")
  end
  
  test "should have and belong to many BusinessSupportSchemes" do
    3.times do |i| 
      @stage.business_support_schemes << BusinessSupportScheme.new(
        title: "Foo scheme #{i + 1}", 
        business_support_identifier: "foo-scheme-#{i + 1}") 
    end
    assert_equal "Foo scheme 1", @stage.business_support_schemes.first.title
    assert_equal "Foo scheme 3", @stage.business_support_schemes.last.title 
  end
  
  test "should validates presence of name" do
    refute BusinessSupportStage.new.valid?
  end
  
  test "should validate uniqueness of name" do
    another_scheme = BusinessSupportStage.new(name: "Finance")
    refute another_scheme.valid?, "should validate uniqueness of name."
  end
end
