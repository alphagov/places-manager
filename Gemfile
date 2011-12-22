source 'http://rubygems.org'

gem 'oauth2', '0.4.1'
gem 'oa-core', '0.2.6'
gem 'oa-oauth', '0.2.6'

gem 'plek', :git => 'git@github.com:alphagov/plek.git'

group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'rails', '~> 3.1.1'

gem "mongoid", "~> 2.3"
gem "mongo", "1.5.2"
gem "bson_ext", "1.5.2"

gem 'exception_notification', '~> 2.5.2', :require => 'exception_notifier'
gem 'formtastic', '~> 2.0.2'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'gds-sso', :git => 'git@github.com:alphagov/gds-sso.git'
end

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', :git => 'git@github.com:alphagov/slimmer.git'
end

gem 'geogov', :git => 'https://github.com/alphagov/geogov.git'
gem 'inherited_resources'
gem 'lockfile'
gem 'whenever'

group :development, :test do
  # gem 'passenger'
  gem 'fabrication'
  gem "timecop"
  gem 'capybara', '~> 1.1.0'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'simplecov', '0.4.2'
  gem 'simplecov-rcov'
  gem 'ci_reporter'
  gem 'test-unit'
end

group :test do
  gem 'mocha'
end
