require_relative "test_helper"
require "capybara/rails"

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

  def assert_current_url(path_with_query, options = {})
    expected = URI.parse(path_with_query)
    current = URI.parse(current_url)
    assert_equal expected.path, current.path
    unless options[:ignore_query]
      assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(current.query)
    end
  end
end

GovukTest.configure
