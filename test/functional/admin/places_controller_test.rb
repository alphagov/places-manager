require 'test_helper'

class Admin::PlacesControllerTest < ActionController::TestCase

  setup do
    @service = FactoryGirl.create(:service)
  end

  context "editing a place" do
    context "given the latest inactive data set" do
      setup do
        @data_set = @service.data_sets.create!(:version => 2)
        @place = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set.version)
      end

      should "display the edit form" do
        as_logged_in_user do
          get :edit, service_id: @service.id, data_set_id: @data_set.id, id: @place.id

          assert_response(:success)
          assert_template "edit"

          assert_equal @place.name, assigns(:place).name
          assert_equal @place.service_slug, assigns(:place).service_slug
        end
      end

      should "persist changes" do
        as_logged_in_user do
          put :update, service_id: @service.id, data_set_id: @data_set.id, id: @place.id,
            place: { name: "Updated Place Name" }

          @place.reload

          assert_equal "Updated Place Name", @place.name
          assert_redirected_to admin_service_data_set_url(@service, @data_set)
        end
      end
    end

    context "given an active data set" do
      setup do
        @data_set = @service.data_sets.create!(:version => 2)
        @place = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set.version)
        @data_set.activate!
      end

      should "not allow the place to be edited" do
        as_logged_in_user do
          get :edit, service_id: @service.id, data_set_id: @data_set.id, id: @place.id

          assert_redirected_to admin_service_data_set_url(@service, @data_set)
        end
      end

      should "not persist changes" do
        as_logged_in_user do
          put :update, service_id: @service.id, data_set_id: @data_set.id, id: @place.id,
            place: { name: "Updated Place Name" }

          assert_response(:unprocessable_entity)
        end
      end
    end

    context "given an inactive data set which is not the latest version" do
      setup do
        @data_set = @service.data_sets.create!(:version => 2)
        @place = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set.version)

        @subsequent_data_set = @service.data_sets.create!(:version => 3)
        @subsequent_data_set.activate!
      end

      should "not allow the place to be edited" do
        as_logged_in_user do
          get :edit, service_id: @service.id, data_set_id: @data_set.id, id: @place.id

          assert_redirected_to admin_service_data_set_url(@service, @data_set)
        end
      end

      should "not persist changes" do
        as_logged_in_user do
          put :update, service_id: @service.id, data_set_id: @data_set.id, id: @place.id,
            place: { name: "Updated Place Name" }

          assert_response(:unprocessable_entity)
        end
      end
    end
  end

end
