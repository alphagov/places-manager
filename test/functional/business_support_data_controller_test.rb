require 'test_helper'

class BusinessSupportDataControllerTest < ActionController::TestCase
  test "GET to show" do
    agriculture = BusinessSupportSector.create(name: "Agriculture")
    manufacturing = BusinessSupportSector.create(name: "Manufacturing")
    get :show, :format => :json, :id => "sector"
    json = JSON.parse(response.body)    
    assert_includes(json.map{|h| h['name']}, "Agriculture")
    assert_includes(json.map{|h| h['name']}, "Manufacturing")
    assert_includes json.map{|h| h['_id']}, agriculture.id.to_s
  end
end
