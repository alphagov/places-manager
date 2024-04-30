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
      it "returns a valid list of rows to pass to a table" do
        rows = @presenter.rows
        expect(rows.any?).to(eq(true))
        rows.each do |row|
          row.each { |column| expect(column.key?(:text)).to(eq(true)) }
        end
      end
    end

    context "#headers" do
      it "returns a valid list of headers to pass to a table" do
        headers = @presenter.headers
        expect(headers.any?).to(eq(true))
        headers.each { |header| expect(header.key?(:text)).to(eq(true)) }
      end
    end

    context "#rows and #headers" do
      it "has the same number of rows and headers" do
        expect((@presenter.rows.first.count == @presenter.headers.count)).to(be_truthy)
      end
    end
  end
end
