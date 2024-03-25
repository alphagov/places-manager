require "test_helper"
require "unit/presenters/table_presenter_shared_examples"

class ServiceDataSetsTablePresenterTest < ActiveSupport::TestCase
  include TablePresenterSharedExamples

  setup do
    stub_search_finds_no_govuk_pages
    @service = FactoryBot.create(:service)
    @presenter = ServiceDataSetsTablePresenter.new(@service, fake_view_context)
  end
end
