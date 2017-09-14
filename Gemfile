source 'http://rubygems.org'

gem 'plek', '~> 1.11.0'

gem 'rails', '5.0.2'
gem 'unicorn', '4.3.1'

gem "mongoid"
gem "mongoid_rails_migrations"

gem 'airbrake', '~> 4.3.8'

gem 'govuk_admin_template', '6.0.0'
gem 'formtastic'
gem 'formtastic-bootstrap'

gem 'gds-api-adapters', '~> 47.9.1'
gem 'statsd-ruby', '1.1.0', require: 'statsd'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', path: '../gds-sso'
else
  gem 'gds-sso', '~> 13.0.0'
end

gem 'responders', '~> 2.0'
gem 'inherited_resources'
gem 'kaminari-mongoid'
gem 'kaminari-actionview'
gem 'bootstrap-kaminari-views', '~> 0.0.3'

gem 'sidekiq', '~> 4.1'
gem 'sidekiq-statsd', '0.1.5'
gem 'redis-namespace', '1.5.2'

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
  gem 'cucumber-rails', require: false
  gem 'capybara'
  gem 'database_cleaner'
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
  gem 'rails-controller-testing'
end
