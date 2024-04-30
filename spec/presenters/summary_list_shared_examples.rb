require "active_support/concern"
module SummaryListSharedExamples
  extend ActiveSupport::Concern

  def fake_view_context
    view = Object.new
    def view.link_to(_link, _target)
      ""
    end
    view
  end

  included do
    context "#summary_list" do
      it "returns a valid summary list" do
        example = @presenter.summary_list(fake_view_context)
        expect(example.key?(:items)).to(eq(true))
        example[:items].each do |item|
          expect(item.key?(:field)).to(eq(true))
          expect(item.key?(:value)).to(eq(true))
        end
      end
    end
  end
end
