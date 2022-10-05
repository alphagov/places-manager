require "test_helper"
require "gds_api/test_helpers/mapit"

class AreasControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::Mapit

  test "search is successful" do
    stub_mapit_has_a_postcode("WC2B 6SE", [51.516, -0.121])

    get :search, params: { postcode: "WC2B 6SE" }, format: :json

    assert_equal 200, response.status

    response_hash = assigns(:presenter).present

    assert_equal "ok", response_hash["_response_info"]["status"]
  end

  test "only permitted area types are successfully routed" do
    assert_raise ActionController::UrlGenerationError do
      get :index, params: { area_type: "FOO" }
    end
  end
end
