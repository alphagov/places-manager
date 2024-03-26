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
      should "return a valid summary list" do
        example = @presenter.summary_list(fake_view_context)

        assert example.key?(:items), "Summary list missing items key"
        example[:items].each do |item|
          assert item.key?(:field), "Item missing a field key"
          assert item.key?(:value), "Item missing a value key"
        end
      end
    end
  end
end
