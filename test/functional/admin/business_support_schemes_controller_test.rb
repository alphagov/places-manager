require 'test_helper'

class Admin::BusinessSupportSchemesControllerTest < ActionController::TestCase
  setup do
    10.times do |i| 
      count = i + 1
      FactoryGirl.create(:business_support_scheme, 
                         title: "Business support scheme #{count}", 
                         business_support_identifier: count)
    end
  end
  test "GET to index" do
    as_logged_in_user do
      get :index
      schemes = assigns(:schemes)
      assert_equal BusinessSupportScheme.count, schemes.size 
      assert_match "Business support scheme 1", response.body
      assert_match "Business support scheme 10", response.body
    end
  end
  test "GET to edit" do
    as_logged_in_user do
      get :edit, id: BusinessSupportScheme.first._id
      assert_equal "Business support scheme 1", assigns(:scheme).title

    end
  end
#  test "PUT to update" do
    #manufacturing = FactoryGirl.create(:business_support_sector, 
                                       #name: 'Manufacturing', 
                                       #slug: 'manufacturing')
    #healthcare = FactoryGirl.create(:business_support_sector, 
                                       #name: 'Healthcare', 
                                       #slug: 'healthcare')

    #scheme = BusinessSupportScheme.last

    #as_logged_in_user do
      #put :update, 
    #end
  #end
end
