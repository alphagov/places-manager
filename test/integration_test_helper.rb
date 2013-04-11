require_relative 'test_helper'
require 'capybara/rails'
require 'govuk_content_models/test_helpers/factories'

DatabaseCleaner.strategy = :truncation

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

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
