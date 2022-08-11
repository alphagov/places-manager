require_relative "test_helper"
require "capybara/rails"

DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner[:active_record].strategy = [:truncation, { except: %w[spatial_ref_sys] }]

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
