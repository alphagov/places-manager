require 'test_helper'

class Admin::ServicesControllerTest < ActionController::TestCase
  test "should create service" do
    as_logged_in_user do
      service_params = {
        "name" => "Register Offices",
        "slug" => "register-offices",
        "location_match_type" => "local_authority",
        "local_authority_hierarchy_match_type" => "county"
      }

      post :create, params: { service: service_params }
      assert_response :redirect

      assert_equal 1, Service.count

      service = Service.last
      assert_equal "Register Offices", service.name
      assert_equal "register-offices", service.slug
      assert_equal "local_authority", service.location_match_type
      assert_equal "county", service.local_authority_hierarchy_match_type
    end
  end
end
