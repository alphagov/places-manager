require "test_helper"
require "unit/presenters/table_presenter_shared_examples"

class ServicesTablePresenterTest < ActiveSupport::TestCase
  include TablePresenterSharedExamples

  setup do
    stub_search_finds_no_govuk_pages
    @service = FactoryBot.create(:service)
    @presenter = ServicesTablePresenter.new([@service], fake_view_context)
  end
end
