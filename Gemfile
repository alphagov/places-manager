source "https://rubygems.org"

ruby "~> 3.3.1"

gem "rails", "7.1.5"

gem "activerecord-postgis-adapter"
gem "bootsnap", require: false
gem "dartsass-rails"
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "inherited_resources"
gem "kaminari"
gem "pg"
gem "plek"
gem "responders"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "state_machines"
gem "state_machines-activerecord"

group :development, :test do
  gem "database_cleaner-active_record"
  gem "erb_lint", require: false
  gem "pact", require: false
  gem "pact_broker-client"
  gem "pry-byebug"
  gem "rubocop-govuk"
end

group :test do
  gem "cucumber-rails", require: false
  gem "factory_bot_rails"
  gem "govuk_test"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "simplecov", require: false
  gem "webmock", require: false
end
