require "test_helper"
require "unit/presenters/summary_list_shared_examples"

class ServicePresenterTest < ActiveSupport::TestCase
  include SummaryListSharedExamples

  setup do
    stub_search_finds_no_govuk_pages
    @service = FactoryBot.create(:service)
    @presenter = ServicePresenter.new(@service)
  end
end
