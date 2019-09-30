source "http://rubygems.org"

gem "plek", "~> 3.0.0"

gem "rails", "5.2.3"

gem "mongoid"
gem "mongoid_rails_migrations"

gem "govuk_admin_template", "6.7.0"
gem "formtastic"
gem "formtastic-bootstrap"

gem "gds-api-adapters", "~> 60.1.0"

if ENV["BUNDLE_DEV"]
  gem "gds-sso", path: "../gds-sso"
else
  gem "gds-sso", "~> 14.1.1"
end

gem "govuk_app_config", "~> 2.0"
gem "govuk_sidekiq", "~> 3.0.3"

gem "responders", "~> 3.0"
gem "inherited_resources"
gem "kaminari-mongoid"
gem "kaminari-actionview"
gem "bootstrap-kaminari-views", "~> 0.0.3"

gem "state_machines", "~> 0.4.0"
gem "state_machines-mongoid", "~> 0.1.1"

gem "sass-rails", "~> 6.0"
gem "uglifier", "4.2.0"

# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 1.0.0", group: :doc

group :development, :test do
  gem "govuk-lint", "4.0.0"
  gem "pry"
end

group :test do
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "govuk_test"
  gem "simplecov", "~> 0.17.1", require: false
  gem "simplecov-rcov", "~> 0.2.3", require: false
  gem "factory_bot_rails", "~> 5.1.0"
  gem "ci_reporter_minitest"
  gem "minitest-reporters"
  gem "launchy"
  gem "shoulda-context"
  gem "mocha", "~> 1.9.0", require: false
  gem "webmock", "~> 3.7.5", require: false
  gem "rails-controller-testing"
end
