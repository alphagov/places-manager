require 'test_helper'
require 'areas_presenter'

class AreasPresenterTest < ActiveSupport::TestCase
  context "presenting an areas by type mapit response" do
    setup do
      bridge = OpenStruct.new(:payload => {
        :code => 200,
        :areas => [ { "id" => 123, "name" => "Westminster City Council", "country_name" => "England", "type" => "LBO" },
                    { "id" => 234, "name" => "London", "country_name" => "England", "type" => "EUR" } ]
      })
      @presenter = AreasPresenter.new(bridge)
    end
    should "format the correct response status" do
      assert_equal "ok", @presenter.present["_response_info"]["status"]
    end
    should "expose the correct data" do
      assert_equal 123, @presenter.present["results"].first["id"]
      assert_equal "Westminster City Council", @presenter.present["results"].first["name"]
      assert_equal "England", @presenter.present["results"].first["country_name"]
      assert_equal 234, @presenter.present["results"].last["id"]
      assert_equal "London", @presenter.present["results"].last["name"]
      assert_equal "England", @presenter.present["results"].last["country_name"]

      refute @presenter.present["results"].first.has_key?("type")
    end
  end
  context "presenting a postcode lookup mapit response" do
    setup do
      response = OpenStruct.new(:payload => {
        :code => 200,
        :areas => [
          { "id" => 123, "name" => "Westminster City Council", "country_name" => "England", "type" => "LBO" },
          { "id" => 234, "name" => "London", "country_name" => "England", "type" => "EUR" }
        ]
      })
      @presenter = AreasPresenter.new(response)
    end
    should "format the correct response status" do
      assert_equal "ok", @presenter.present["_response_info"]["status"]
    end
    should "expose the correct data" do
      assert_equal 123, @presenter.present["results"].first["id"]
      assert_equal "Westminster City Council", @presenter.present["results"].first["name"]
      assert_equal "England", @presenter.present["results"].first["country_name"]
      assert_equal 234, @presenter.present["results"].last["id"]
      assert_equal "London", @presenter.present["results"].last["name"]
      assert_equal "England", @presenter.present["results"].last["country_name"]
    end
  end
end
