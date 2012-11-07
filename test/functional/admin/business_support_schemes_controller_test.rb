require 'test_helper'

class Admin::BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do
    @titles = ["Super finance triple bonus", "Young business starter award",
               "Brilliant start-up award", "Wunderbiz"]

    @sectors = ["Agriculture", "Healthcare", "Manufacturing"]
    @stages = ["Pre-startup", "Startup", "Grow and sustain"]
    
    @sectors.each do |name|
      FactoryGirl.create(:business_support_sector, name: name, slug: name.parameterize)
    end
    
    @stages.each do |name|
      FactoryGirl.create(:business_support_stage, name: name, slug: name.parameterize)
    end
    
    @titles.each_with_index do |title, index|
      FactoryGirl.create(:business_support_scheme, 
                         title: title, 
                         business_support_identifier: index + 1)
    end
  end

  test "GET to index" do
    as_logged_in_user do
      get :index
      schemes = assigns(:schemes)
      assert_equal BusinessSupportScheme.count, schemes.size 
      assert_match "Wunderbiz", response.body
      assert_match "Young business starter award", response.body
      assert_equal BusinessSupportScheme.asc(:title), schemes
    end
  end
  
  test "GET to edit" do
    as_logged_in_user do
      scheme = BusinessSupportScheme.first
      get :edit, id: scheme._id
      assert_equal scheme, assigns(:scheme)
      assert_equal 3, assigns(:sectors).size
      assert_equal 3, assigns(:stages).size
    end
  end

  test "PUT to update" do

    scheme = BusinessSupportScheme.last
    scheme.business_support_sectors << BusinessSupportSector.where(slug: 'manufacturing').first 
    scheme.save!

    as_logged_in_user do
      #put :update, 
    end
  end
end
