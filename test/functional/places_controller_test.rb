require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  def setup_service
    Service.first || Service.create(:name => 'Important Government Service', :slug => 'important-government-service')
  end
  
  test "as a logged in user I can access a non-active data set" do
    as_logged_in_user do
      get :show, :id => setup_service.slug, :format => :json
      assert_response :success
    end
  end
end
