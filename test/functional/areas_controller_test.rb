require 'test_helper'

class AreasControllerTest < ActionController::TestCase
  test "the index action responds successfully" do
    Imminence.mapit_api.stubs(:areas_for_type)
    MapitApi::AreasByTypeResponse.any_instance.stubs(:payload).returns(
      code: 200,
      areas: []
    )

    get :index, { area_type: 'CTY', format: :json }

    response_hash = assigns(:presenter).present

    assert_equal "ok", response_hash["_response_info"]["status"]
  end

  test "search is successful" do
    Imminence.mapit_api.stubs(:location_for_postcode)
    MapitApi::AreasByPostcodeResponse.any_instance.stubs(:payload).returns(
      code: 200,
      areas: []
    )

    get :search, { postcode: "WC2B 6SE", format: :json }

    assert_equal 200, response.status

    response_hash = assigns(:presenter).present

    assert_equal "ok", response_hash["_response_info"]["status"]
  end

  test "only permitted area types are successfully routed" do
    assert_raise ActionController::UrlGenerationError do
      get :index, { area_type: 'FOO' }
    end
  end

  test "typos in postcodes are silently corrected" do
    # This is what the postcode searched for should be transformed to.
    Imminence.mapit_api.stubs(:location_for_postcode).with("WC2B 6NH")
    MapitApi::AreasByPostcodeResponse.any_instance.stubs(:payload).returns(
      :code => 200,
      :areas => []
    )

    get :search, { :postcode => "WC2B-6NH] ", :format => :json }

    assert_equal 200, response.status

    response_hash = assigns(:presenter).present

    assert_equal "ok", response_hash["_response_info"]["status"]
  end
end
