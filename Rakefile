# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)
if Rails.env.development? || Rails.env.test?
  require "ci/reporter/rake/minitest"
end

Rails.application.load_tasks
task test: :check_for_bad_time_handling
