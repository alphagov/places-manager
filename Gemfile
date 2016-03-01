source 'http://rubygems.org'

gem 'plek', '~> 1.11.0'

gem 'rails', '4.2.5.2'
gem 'unicorn', '4.3.1'

gem "mongoid", "~> 4.0"
gem "mongoid_rails_migrations", "~> 1.1.0"

gem 'airbrake', '~> 4.1.0'

gem 'govuk_admin_template', '3.0.0'
gem 'formtastic', '~> 3.1.2'
gem 'formtastic-bootstrap', '~> 3.1.1'

gem 'gds-api-adapters', '~> 24.5.0'
gem 'statsd-ruby', '1.1.0', require: 'statsd'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', path: '../gds-sso'
else
  gem 'gds-sso', '~> 11.0.0'
end

gem 'responders', '~> 2.0'
gem 'inherited_resources', '~> 1.6.0'
gem 'kaminari', '~> 0.16.0'
gem 'bootstrap-kaminari-views', '~> 0.0.3'

gem 'sidekiq', '~> 2.16'
gem 'sidekiq-statsd', '0.1.5'

gem 'state_machines-mongoid', '~> 0.1.1'
gem 'logstasher', '0.4.8'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '2.7.2'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

group :development, :test do
  gem 'pry'
  gem 'govuk-lint', '0.5.1'
end

group :test do
  gem 'cucumber-rails', '~> 1.4.0', require: false
  gem 'capybara', '~> 2.5.0'
  # NOTE: 1.5.0 has a bug with mongoid and truncation: https://github.com/DatabaseCleaner/database_cleaner/issues/299
  gem 'database_cleaner', '~> 1.4.0'
  gem 'simplecov', '~> 0.10.0', require: false
  gem 'simplecov-rcov', '~> 0.2.3', require: false
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'ci_reporter_minitest'
  gem 'minitest-reporters'
  gem 'launchy'
  gem 'shoulda-context'
  gem 'mocha', '~> 1.1.0', require: false
  gem 'poltergeist', '~> 1.7.0'
  gem 'webmock', '~> 1.11', require: false
end
