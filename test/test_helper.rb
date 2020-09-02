if ENV["COVERAGE"]
  require "simplecov"
  require "simplecov-rcov"

  SimpleCov.start "rails"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require "database_cleaner"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "mocha/minitest"
require "gds_api/test_helpers/json_client_helper"
require "gds_api/test_helpers/mapit"
require "webmock/minitest"
require "govuk_sidekiq/testing"
# Poltergeist requires access to localhost.
WebMock.disable_net_connect!(allow_localhost: true)

require "minitest/reporters"
reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def clean_db
    DatabaseCleaner.clean
  end
  set_callback :teardown, :before, :clean_db

  def reset_sidekiq_testing
    Sidekiq::Testing.fake!
  end
  set_callback :setup, :before, :reset_sidekiq_testing

  def as_logged_in_user(&_block)
    @controller.stubs(:authenticate_user!).returns(true)
    @controller.stubs(:user_signed_in?).returns(true)
    @controller.stubs(:current_user).returns(User.new)
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

  def stub_mapit_postcode_response_from_fixture(postcode)
    fixture_file = fixture_file_path("mapit_responses/#{postcode.tr(' ', '_')}.json")

    stub_request(:get, "#{GdsApi::TestHelpers::Mapit::MAPIT_ENDPOINT}/postcode/#{postcode.tr(' ', '+')}.json")
      .to_return(body: File.open(fixture_file), status: 200, headers: { "Content-Type" => "application/json" })
  end
end
