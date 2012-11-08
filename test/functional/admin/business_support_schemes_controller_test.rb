require 'test_helper'

class Admin::BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do
    @titles = ["Super finance triple bonus", "Young business starter award",
               "Brilliant start-up award", "Wunderbiz"]

    @locations = ["England", "Scotland", "Wales", "Northern Ireland"]
    @sectors = ["Agriculture", "Healthcare", "Manufacturing"]
    @stages = ["Pre-startup", "Startup", "Grow and sustain"]
    
    @locations.each do |name|
      FactoryGirl.create(:business_support_location, name: name, slug: name.parameterize)
    end

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
      assert_equal 4, assigns(:locations).size
      assert_equal "Wales", assigns(:locations).last.name
      assert_equal 3, assigns(:sectors).size
      assert_equal 3, assigns(:stages).size
    end
  end

  test "PUT to update" do
    scheme = BusinessSupportScheme.last
    
    scotland = BusinessSupportLocation.where(slug: 'scotland').first
    england = BusinessSupportLocation.where(slug: 'england').first
    manufacturing = BusinessSupportSector.where(slug: 'manufacturing').first
    
    scheme.business_support_sectors << manufacturing 
    scheme.business_support_locations << england
    scheme.save!

    as_logged_in_user do
      put :update, id: scheme._id, business_support_scheme: { title: scheme.title,
        business_support_identifier: scheme.business_support_identifier,
        business_support_location_ids: [england._id, scotland._id],
        business_support_sector_ids: [manufacturing._id]
      }
      scheme.reload
      assert_equal 2, scheme.business_support_locations.size
      assert_equal 302, response.status
    end
  end

  test "PUT to update with bad params" do
    scheme = BusinessSupportScheme.last
    other_scheme = BusinessSupportScheme.first
    as_logged_in_user do
      put :update, id: scheme._id, business_support_scheme: { title: other_scheme.title }
      scheme.reload
      refute_equal scheme.title, other_scheme.title
    end
  end
end
