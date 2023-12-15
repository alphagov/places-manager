source "https://rubygems.org"

ruby "~> 3.2.0"

gem "rails", "7.1.2"

gem "activerecord-postgis-adapter"
gem "bootsnap", require: false
gem "bootstrap-kaminari-views"
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_admin_template"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "inherited_resources"
gem "kaminari"
gem "pg"
gem "plek"
gem "responders"
gem "sass-rails"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "state_machines"
gem "state_machines-activerecord"
gem "uglifier"

group :development, :test do
  gem "database_cleaner-active_record"
  gem "pact", require: false
  gem "pact_broker-client"
  gem "pry-byebug"
  gem "rubocop-govuk"
end

group :test do
  gem "ci_reporter_minitest"
  gem "cucumber-rails", require: false
  gem "factory_bot_rails"
  gem "govuk_test", ">= 4.0.2"
  gem "launchy"
  gem "minitest-reporters"
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "shoulda-context"
  gem "simplecov", require: false
  gem "webmock", require: false
end
