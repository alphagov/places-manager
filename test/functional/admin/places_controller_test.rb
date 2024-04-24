require "test_helper"

class Admin::PlacesControllerTest < ActionController::TestCase
  setup do
    @data_set = FactoryBot.create(:data_set)
  end

  context "GET (:service/:data_set/:place)" do
    should "display place details" do
      as_gds_editor do
        get :show, params: { service_id: @data_set.service.id, data_set_id: @data_set.id, id: @data_set.places.first.id }

        assert_response(:success)
      end
    end

    should "reject if user is not in the appropriate department" do
      as_other_department_user do
        get :show, params: { service_id: @data_set.service.id, data_set_id: @data_set.id, id: @data_set.places.first.id }

        assert_response(:forbidden)
      end
    end
  end
end
