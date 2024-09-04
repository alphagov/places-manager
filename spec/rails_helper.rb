ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage line: 90
  add_filter "lib/tasks/cucumber.rake"
  add_filter "lib/tasks/lint.rake"
end

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "webmock/rspec"
require "govuk_sidekiq/testing"
require "capybara/rails"

Rails.application.load_tasks

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
GovukTest.configure
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end
