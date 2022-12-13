source "https://rubygems.org"

gem "rails", "7.0.4"

gem "bootstrap-kaminari-views"
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_admin_template"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "inherited_resources"
gem "kaminari-actionview"
gem "kaminari-mongoid"
gem "mail", "~> 2.7.1"  # TODO: remove once https://github.com/mikel/mail/issues/1489 is fixed.
gem "mongo", "2.15.1"
gem "mongoid"
gem "plek"
gem "responders"
gem "sass-rails"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "state_machines"
gem "state_machines-mongoid"
gem "uglifier"

group :development, :test do
  gem "database_cleaner-mongoid"
  gem "pact", require: false
  gem "pact_broker-client"
  gem "pry-byebug"
  gem "rubocop-govuk"
end

group :test do
  gem "ci_reporter_minitest"
  gem "cucumber-rails", require: false
  gem "factory_bot_rails"
  gem "govuk_test"
  gem "launchy"
  gem "minitest-reporters"
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "shoulda-context"
  gem "simplecov", require: false
  gem "webmock", require: false
end
