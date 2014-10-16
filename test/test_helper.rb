if ENV["COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require 'database_cleaner'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'
require 'gds_api/test_helpers/json_client_helper'
require 'gds_api/test_helpers/mapit'
require 'webmock/minitest'
require 'sidekiq/testing'
# Poltergeist requires access to localhost.
WebMock.disable_net_connect!(:allow_localhost => true)

# Now that mongoid no longer has the autocreate_indexes config option,
# we need to ensure that the indexes exist in the test databse (the 
# geo lookup functions won't work without them)
silence_stream(STDOUT) do
  Rails::Mongoid.create_indexes
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  include MiniTest::Assertions

  def clean_db
    DatabaseCleaner.clean
  end
  set_callback :teardown, :before, :clean_db


  def as_logged_in_user(&block)
    @controller.stubs(:authenticate_user!).returns(true)
    @controller.stubs(:require_signin_permission!).returns(true)
    @controller.stubs(:user_signed_in?).returns(true)
    @controller.stubs(:current_user).returns(User.new)
    yield
    @controller.unstub(:current_user)
    @controller.unstub(:user_signed_in?)
    @controller.unstub(:require_signin_permission!)
    @controller.unstub(:authenticate_user!)
  end

  def create_test_user
    FactoryGirl.create(:user)
  end

  def fixture_file_path(basename)
    Rails.root.join("test", "fixtures", basename)
  end

  def stub_mapit_postcode_response_from_fixture(postcode)
    fixture_file = fixture_file_path("mapit_responses/#{postcode.gsub(' ', '_')}.json")

    stub_request(:get, "#{GdsApi::TestHelpers::Mapit::MAPIT_ENDPOINT}/postcode/#{postcode.gsub(' ','+')}.json").
      to_return(:body => File.open(fixture_file), :status => 200, :headers => {'Content-Type' => 'application/json'})
  end
end
