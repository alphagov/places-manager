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
require 'mocha'

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
  
end
