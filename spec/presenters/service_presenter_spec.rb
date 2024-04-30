require "rails_helper"
require "presenters/summary_list_shared_examples"
RSpec.describe(ServicePresenter, type: :model) do
  include SummaryListSharedExamples

  before do
    stub_search_finds_no_govuk_pages
    @service = FactoryBot.create(:service)
    @presenter = ServicePresenter.new(@service)
  end
end
