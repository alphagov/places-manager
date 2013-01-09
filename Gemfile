source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'plek', '1.0.0'

gem 'rails', '3.2.8'
gem 'unicorn', '4.3.1'

gem "mongoid", "2.4.10"
gem "mongo", "1.6.2"
gem "bson_ext", "1.6.2"

gem 'aws-ses', :require => 'aws/ses'
gem 'exception_notification', '2.5.2', :require => 'exception_notifier'

gem 'formtastic', git: 'https://github.com/justinfrench/formtastic.git', branch: '2.1-stable'
gem 'formtastic-bootstrap', git: 'https://github.com/cgunther/formtastic-bootstrap.git', branch: 'bootstrap-2'
gem 'jquery-rails'
gem 'less-rails-bootstrap'

gem 'gds-api-adapters', '4.1.3'
gem 'govuk_content_models', '2.5.1'
gem 'statsd-ruby', '1.0.0', :require => 'statsd'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'gds-sso', '2.1.0'
end
gem "faraday", "0.8.1" # Specifying to resolve Jenkins dependency resolution fail

gem 'geogov', '0.0.9'
gem 'govspeak', '~> 1.2'

gem 'inherited_resources'
gem 'lockfile'
gem 'whenever'
gem 'lograge'
gem 'kaminari', '0.14.1'
gem 'kaminari-bootstrap', '0.1.3'

group :assets do
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end

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
  gem 'shoulda', '3.3.1'
  gem 'mocha', '0.12.3', require: false
  gem 'poltergeist', '0.7.0'
end
