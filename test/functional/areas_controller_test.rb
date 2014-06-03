require 'test_helper'

class AreasControllerTest < ActionController::TestCase
  test "the index action responds successfully" do
    Imminence.mapit_api.stubs(:areas_for_type).returns(
      OpenStruct.new(:code => 200, :to_hash => {
      '123' => { 'name' => 'Narnia County Council' },
      '234' => { 'name' => 'Toytown District Council' }
    }))
    get :index, { :area_type => 'CTY', :format => :json }

    assert_equal 200, response.status

    response_hash = assigns(:presenter).present

    assert_equal "ok", response_hash["_response_info"]["status"]
    assert_equal 2, response_hash["results"].size
    assert_equal "Narnia County Council", response_hash["results"].first["name"]
    assert_equal "Toytown District Council", response_hash["results"].last["name"]
  end

  test "only permitted area types are successfully routed" do
    assert_raise ActionController::RoutingError do
      get :index, { :area_type => 'FOO' }
    end
  end
end
