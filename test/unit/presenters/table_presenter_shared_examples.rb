require "active_support/concern"

module TablePresenterSharedExamples
  extend ActiveSupport::Concern

  def fake_view_context
    view = Object.new

    def view.link_to(_link, _target)
      ""
    end

    def view.truncate(_value, _params)
      ""
    end

    def view.admin_service_path(_service)
      ""
    end

    def view.admin_service_data_set_path(_params)
      ""
    end

    def view.admin_service_data_set_place_path(_service, _data_set, _place)
      ""
    end

    view
  end

  included do
    context "#rows" do
      should "return a valid list of rows to pass to a table" do
        rows = @presenter.rows

        assert rows.any?, "Table has no rows"
        rows.each do |row|
          row.each do |column|
            assert column.key?(:text), "Row item missing a text key"
          end
        end
      end
    end

    context "#headers" do
      should "return a valid list of headers to pass to a table" do
        headers = @presenter.headers

        assert headers.any?, "Table has no headers"
        headers.each do |header|
          assert header.key?(:text), "Header item missing a text key"
        end
      end
    end

    context "#rows and #headers" do
      should "have the same number of rows and headers" do
        assert(@presenter.rows.first.count == @presenter.headers.count, "Headers and rows have a different number of columns")
      end
    end
  end
end
