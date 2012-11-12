require 'business_support_test_helper'

class Admin::BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do

    make_facets(:business_support_business_type, ["Pre-startup", "Startup", "Private company", "Charity"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    ["Super finance triple bonus", "Young business starter award", "Brilliant start-up award", "Wunderbiz"
      ].each_with_index do |title, index|
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
      assert_equal BusinessSupportScheme.asc(:title), schemes
    end
  end

  test "GET to new" do
    as_logged_in_user do
      FactoryGirl.create(:business_support_scheme,
                        title: "Superfoo award",
                        business_support_identifier: "333",
                        priority: 1)
      get :new
      refute_nil assigns(:scheme), "scheme should be initialized"
      assert_equal "334", assigns(:scheme).business_support_identifier
    end
  end

  test "POST to create" do
    as_logged_in_user do
      post :create, business_support_scheme: {
        title: "Strategic advice for ice cream vendors",
        business_support_identifier: "334",
        priority: 2
      }
      bs = BusinessSupportScheme.last
      assert_equal "Strategic advice for ice cream vendors", bs.title
      assert_equal "334", bs.business_support_identifier
      assert_equal 2, bs.priority
      assert_equal 302, response.status
    end
  end

  test "POST to create with bad parameters" do
     as_logged_in_user do
      post :create, business_support_scheme: {
        title: "Wunderbiz",
        business_support_identifier: "2",
        priority: 3
      }
      refute assigns(:scheme).valid?, "this scheme should be invalid"
      refute_equal BusinessSupportScheme.last, assigns(:scheme)
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
    
    scheme.business_support_sectors << @manufacturing 
    scheme.business_support_locations << @england
    scheme.save!

    as_logged_in_user do
      put :update, id: scheme._id, business_support_scheme: { title: scheme.title,
        business_support_identifier: scheme.business_support_identifier,
        business_support_location_ids: [@england._id, @scotland._id],
        business_support_sector_ids: [@manufacturing._id],
        priority: 2
      }
      scheme.reload
      assert_equal [@england, @scotland], scheme.business_support_locations
      assert_equal 2, scheme.priority
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
