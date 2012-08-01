source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'gelf'
gem 'plek', '~> 0'
gem 'gds-warmup-controller'

group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'rails', '~> 3.1.1'

gem "mongoid", "2.4.10"
gem "mongo", "1.5.2"
gem "bson_ext", "1.5.2"

gem 'aws-ses', :require => 'aws/ses'
gem 'exception_notification', '~> 2.5.2', :require => 'exception_notifier'
gem 'formtastic', '~> 2.0.2'

gem 'govuk_content_models', '0.2.2'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'gds-sso', '~> 1.2.0'
end
gem "faraday", "0.8.1" # Specifying to resolve Jenkins dependency resolution fail

gem 'geogov', '0.0.9'
gem 'inherited_resources'
gem 'lockfile'
gem 'whenever'
gem 'lograge'

group :development, :test do
  gem 'cucumber-rails', require: false
  gem 'fabrication'
  gem "timecop"
  gem 'capybara', '~> 1.1.0'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'simplecov', '0.4.2'
  gem 'simplecov-rcov'
  gem 'factory_girl', "3.3.0"
  gem 'factory_girl_rails'
  gem 'ci_reporter'
  gem 'test-unit'
  gem 'launchy'
end

group :test do
  gem 'mocha'
end
