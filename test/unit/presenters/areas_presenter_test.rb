require "test_helper"
require "areas_presenter"

class AreasPresenterTest < ActiveSupport::TestCase
  context "presenting a mapit response" do
    setup do
      bridge = OpenStruct.new(payload: {
        code: 200,
        areas: [
          {
            "id" => 123,
            "name" => "Westminster City Council",
            "country_name" => "England",
            "type" => "LBO",
            "codes" => {
              "gss" => "E09000033",
            },
          },
          {
            "id" => 234,
            "name" => "London",
            "country_name" => "England",
            "type" => "EUR",
            "codes" => {
              "gss" => "E15000007",
            },
          },
        ],
      })
      @presenter = AreasPresenter.new(bridge)
    end

    should "format the correct response status" do
      assert_equal "ok", @presenter.present["_response_info"]["status"]
    end

    context "first result" do
      setup do
        @result = @presenter.present["results"].first
      end

      should "expose the correct data" do
        assert_not @result.key?("slug")
        assert_equal "Westminster City Council", @result["name"]
        assert_equal "England", @result["country_name"]
        assert_equal "LBO", @result["type"]
        assert_equal "E09000033", @result["codes"]["gss"]

        assert_not @result.has_key?("parent_area")
      end
    end

    context "second result" do
      setup do
        @result = @presenter.present["results"][1]
      end

      should "expose the correct data" do
        assert_not @result.key?("slug")
        assert_equal "London", @result["name"]
        assert_equal "England", @result["country_name"]
        assert_equal "EUR", @result["type"]
        assert_equal "E15000007", @result["codes"]["gss"]
      end
    end
  end
end
