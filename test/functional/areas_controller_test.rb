require "test_helper"
require "gds_api/test_helpers/mapit"

class AreasControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::Mapit

  test "the index action responds successfully" do
    mapit_has_areas("CTY",
                    '2217': {
                      'id': 2217,
                      'codes': { 'ons': "11", 'gss': "E10000002", 'govuk_slug': "buckinghamshire" },
                      'name': "Buckinghamshire County Council",
                      'country': "E",
                      'type_name': "County council",
                      'country_name': "England",
                      'type': "CTY",
                    })

    get :index, params: { area_type: "CTY" }, format: :json

    response_hash = assigns(:presenter).present

    assert_equal "ok", response_hash["_response_info"]["status"]
  end

  test "search is successful" do
    mapit_has_a_postcode("WC2B 6SE", [51.516, -0.121])

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
