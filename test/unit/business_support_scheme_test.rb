require 'test_helper'

class BusinessSupportSchemeTest < ActiveSupport::TestCase

  describe BusinessSupportScheme do
    
    it "should validate presence of title" do
      @scheme = BusinessSupportScheme.new
      refute @scheme.valid?, "BusinessSupportScheme should validate presence of title."
      @scheme.title = "Foo scheme"
      assert @scheme.valid?, "BusinessSupportScheme should validate presence of title."
    end
    
    it "should validate uniqueness of title" do
      @scheme = BusinessSupportScheme.new title: "Foo"
      assert @scheme.valid?, "BusinessSupportScheme should validate uniqueness of title."
      @another_scheme = BusinessSupportScheme.new title: "Foo"
      refute @another_scheme.valid?, "BusinessSupportScheme should validate uniqueness of title."
    end
    
    it "should have and belong to many BusinessSupportSectors" do
      @scheme = BusinessSupportScheme.new title: "Foo scheme"
      3.times { |i| @scheme.business_support_sectors << BusinessSupportSector.new(title: "Foo sector #{i + 1}") }
      assert_equal "Foo sector 1", @scheme.business_support_sectors.first.title
      assert_equal "Foo sector 3", @scheme.business_support_sectors.last.title 
    end
    
  end

end
