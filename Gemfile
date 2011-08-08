source 'http://rubygems.org'

gem 'rails', '~> 3.0.9'

gem "mongoid", "~> 2.0"
gem "bson_ext", "~> 1.3"

gem 'exception_notification', '~> 2.4.1', :require => 'exception_notifier'
gem 'formtastic'

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

group :development, :test do
  # gem 'passenger'
  gem 'fabrication'
  gem "timecop"
  gem 'capybara', '~> 1.0.0'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
end
