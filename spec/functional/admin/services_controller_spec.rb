require "rails_helper"

module Admin
  RSpec.describe(ServicesController, type: :controller) do
    it "creates a service" do
      as_gds_editor do
        csv_file = fixture_file_upload(Rails.root.join("spec/fixtures/good_csv.csv"), "text/csv")
        service_params = { name: "Register Offices", slug: "register-offices", organisation_slugs: "government-digital-service test-service", location_match_type: "local_authority", local_authority_hierarchy_match_type: "county", data_file: csv_file }
        post(:create, params: { service: service_params })
        assert_response(:redirect)
        expect(Service.count).to(eq(1))
        service = Service.last
        expect(service.name).to(eq("Register Offices"))
        expect(service.slug).to(eq("register-offices"))
        expect(service.organisation_slugs).to(eq(%w[government-digital-service test-service]))
        expect(service.location_match_type).to(eq("local_authority"))
        expect(service.local_authority_hierarchy_match_type).to(eq("county"))
      end
    end

    context "with a service created by test-department" do
      before do
        @service = FactoryBot.create(:service)
        stub_search_finds_no_govuk_pages
      end

      it "is not visible to other-department user" do
        as_other_department_user do
          get(:show, params: { id: @service.id })
          assert_response(:forbidden)
        end
      end

      it "is visible to test-department user" do
        as_test_department_user do
          get(:show, params: { id: @service.id })
          assert_response(:ok)
        end
      end

      it "is visible to GDS Editor" do
        as_gds_editor do
          get(:show, params: { id: @service.id })
          assert_response(:ok)
        end
      end
    end
  end
end
