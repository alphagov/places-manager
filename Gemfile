source 'http://rubygems.org'

gem 'plek', '1.3.1'

gem 'rails', '3.2.17'
gem 'unicorn', '4.3.1'

gem "mongoid", "3.1.5"
gem "mongoid_rails_migrations", "1.0.0"

gem 'aws-ses', :require => 'aws/ses'
gem 'exception_notification', '2.5.2', :require => 'exception_notifier'

gem 'formtastic', git: 'https://github.com/justinfrench/formtastic.git', branch: '2.1-stable'
gem 'formtastic-bootstrap', git: 'https://github.com/cgunther/formtastic-bootstrap.git', branch: 'bootstrap-2'
gem 'jquery-rails'
gem 'less-rails-bootstrap'

gem 'gds-api-adapters', '10.13.0'
gem 'statsd-ruby', '1.0.0', :require => 'statsd'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', :path => '../gds-sso'
else
  gem 'gds-sso', '9.3.0'
end
gem "faraday", "0.8.1" # Specifying to resolve Jenkins dependency resolution fail

gem 'govspeak', '~> 1.2'

gem 'inherited_resources'
gem 'lockfile'
gem 'whenever'
gem 'kaminari', '0.14.1'
gem 'kaminari-bootstrap', '0.1.3'

gem 'sidekiq', '2.16.1'
gem 'sidekiq-delay', '1.0.4'

gem 'state_machine', '1.2.0'
gem 'logstasher', '0.4.8'

group :assets do
  gem "therubyracer", "0.11.4"
  gem 'uglifier'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'capybara', '1.1.2'
  gem 'database_cleaner', '1.0.1'
  gem 'simplecov', '0.6.4'
  gem 'simplecov-rcov', '0.2.3'
  gem 'factory_girl', "3.3.0"
  gem 'factory_girl_rails'
  gem 'ci_reporter', '1.7.1'
  gem 'minitest', '3.3.0'
  gem 'launchy'
  gem 'shoulda', '3.3.1'
  gem 'mocha', '0.13.3', require: false
  gem 'poltergeist', '0.7.0'
  gem 'timecop', '0.5.9.2'
  gem 'webmock', '1.11.0', :require => false
end
