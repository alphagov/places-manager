require "test_helper"

class Admin::ServicesControllerTest < ActionController::TestCase
  test "should create service" do
    as_gds_editor do
      csv_file = fixture_file_upload(Rails.root.join("test/fixtures/good_csv.csv"), "text/csv")

      service_params = {
        name: "Register Offices",
        slug: "register-offices",
        organisation_slugs: "government-digital-service test-service",
        location_match_type: "local_authority",
        local_authority_hierarchy_match_type: "county",
        data_file: csv_file,
      }

      post :create, params: { service: service_params }
      assert_response :redirect

      assert_equal 1, Service.count

      service = Service.last
      assert_equal "Register Offices", service.name
      assert_equal "register-offices", service.slug
      assert_equal %w[government-digital-service test-service], service.organisation_slugs
      assert_equal "local_authority", service.location_match_type
      assert_equal "county", service.local_authority_hierarchy_match_type
    end
  end

  context "with a service created by test-department" do
    setup do
      @service = FactoryBot.create(:service)
      stub_search_finds_no_govuk_pages
    end

    should "not be visible to other-department user" do
      as_other_department_user do
        get :show, params: { id: @service.id }

        assert_response :forbidden
      end
    end

    should "be visible to test-department user" do
      as_test_department_user do
        get :show, params: { id: @service.id }

        assert_response :ok
      end
    end

    should "be visible to GDS Editor" do
      as_gds_editor do
        get :show, params: { id: @service.id }

        assert_response :ok
      end
    end
  end
end
