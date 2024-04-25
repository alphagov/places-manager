require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
end

require "database_cleaner-active_record"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "mocha/minitest"
require "gds_api/test_helpers/json_client_helper"
require "gds_api/test_helpers/locations_api"
require "gds_api/test_helpers/organisations"
require "webmock/minitest"
require "govuk_sidekiq/testing"
# Poltergeist requires access to localhost.
WebMock.disable_net_connect!(allow_localhost: true)

DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner[:active_record].strategy = [:truncation, { except: %w[spatial_ref_sys] }]

require "minitest/reporters"
reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class ActiveSupport::TestCase
  include GdsApi::TestHelpers::Organisations
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  setup do
    DatabaseCleaner.clean
  end

  teardown do
    DatabaseCleaner.clean
  end

  def clean_db
    DatabaseCleaner.clean
  end

  def reset_sidekiq_testing
    Sidekiq::Testing.fake!
  end
  set_callback :setup, :before, :reset_sidekiq_testing

  def as_gds_editor(&block)
    as_logged_in_user(["GDS Editor"], "government-digital-service", &block)
  end

  def as_test_department_user(&block)
    as_logged_in_user([], "test-department", &block)
  end

  def as_other_department_user(&block)
    as_logged_in_user([], "other-department", &block)
  end

  def as_logged_in_user(permissions, organisation_slug, &_block)
    @controller.stubs(:authenticate_user!).returns(true)
    @controller.stubs(:user_signed_in?).returns(true)
    @controller.stubs(:current_user).returns(User.new(permissions:, organisation_slug:))
    yield
    @controller.unstub(:current_user)
    @controller.unstub(:user_signed_in?)
    @controller.unstub(:authenticate_user!)
  end

  def create_test_user
    FactoryBot.create(:user)
  end

  def fixture_file_path(basename)
    Rails.root.join("test", "fixtures", basename)
  end

  def stub_locations_api_postcode_is_invalid(postcode)
    stub_request(:get, "#{GdsApi::TestHelpers::LocationsApi::LOCATIONS_API_ENDPOINT}/v1/locations?postcode=#{postcode}")
      .to_return(body: { "errors" => { "postcode" => ["This postcode is invalid"] } }.to_json, status: 400)
  end

  def stub_locations_api_does_not_have_a_postcode(postcode)
    stub_request(:get, "#{GdsApi::TestHelpers::LocationsApi::LOCATIONS_API_ENDPOINT}/v1/locations?postcode=#{postcode}")
      .to_return(body: { "errors" => { "postcode" => ["No results found for given postcode"] } }.to_json, status: 404)
  end

  def stub_organisations_test_department
    stub_organisations_api_has_organisations_with_bodies([{ "title" => "Department of Testing", "details" => { "slug" => "test-department" } }])
  end

  def stub_search_finds_no_govuk_pages
    stub_request(:get, "http://search-api.dev.gov.uk/search.json?count=200&fields=title,link&filter_format=place").to_return(status: 200, body: { results: [] }.to_json, headers: {})
  end
end

GovukTest.configure
