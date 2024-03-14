require "test_helper"

class Admin::PlacesControllerTest < ActionController::TestCase
  setup do
    @service = FactoryBot.create(:service)
  end
end
