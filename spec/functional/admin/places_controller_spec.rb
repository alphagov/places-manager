require "rails_helper"

module Admin
  RSpec.describe(PlacesController, type: :controller) do
    before { @data_set = FactoryBot.create(:data_set) }

    describe "GET (:service/:data_set/:place)" do
      it "display place details" do
        as_gds_editor do
          get(:show, params: { service_id: @data_set.service.id, data_set_id: @data_set.id, id: @data_set.places.first.id })
          assert_response(:success)
        end
      end

      it "reject if user is not in the appropriate department" do
        as_other_department_user do
          get(:show, params: { service_id: @data_set.service.id, data_set_id: @data_set.id, id: @data_set.places.first.id })
          assert_response(:forbidden)
        end
      end
    end
  end
end
