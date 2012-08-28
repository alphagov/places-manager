source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'gelf'
gem 'plek', '0.1.24'
gem 'gds-warmup-controller'

gem 'rails', '3.2.7'

gem "mongoid", "2.4.10"
gem "mongo", "1.5.2"
gem "bson_ext", "1.5.2"

gem 'aws-ses', :require => 'aws/ses'
gem 'exception_notification', '2.5.2', :require => 'exception_notifier'
gem 'formtastic', '2.0.2'

gem 'govuk_content_models', '1.6.3'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'gds-sso', '1.2.0'
end
gem "faraday", "0.8.1" # Specifying to resolve Jenkins dependency resolution fail

# Required but not set as a dependency for slimmer
gem 'gds-api-adapters'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '1.1.42'
end

gem 'geogov', '0.0.9'
gem 'inherited_resources'
gem 'lockfile'
gem 'whenever'
gem 'lograge'

group :test do
  gem 'cucumber-rails', require: false
  gem 'capybara', '1.1.2'
  gem 'database_cleaner'
  gem 'simplecov', '0.6.4'
  gem 'simplecov-rcov', '0.2.3'
  gem 'factory_girl', "3.3.0"
  gem 'factory_girl_rails'
  gem 'ci_reporter', '1.7.1'
  gem 'minitest', '3.3.0'
  gem 'launchy'
  gem 'mocha', '0.12.3', require: false
end
