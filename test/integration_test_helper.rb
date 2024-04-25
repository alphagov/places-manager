require_relative "test_helper"
require "capybara/rails"

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Rack::Test::Methods

  setup do
    DatabaseCleaner.clean
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.use_default_driver
  end
end

GovukTest.configure
