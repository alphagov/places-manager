# FIXME: remove this once we've transitioned to starting sidekiq from the Procfile
namespace :jobs do
  task :work do
    base_path = File.expand_path('../..', __dir__)
    exec("bundle exec sidekiq -C #{base_path}/config/sidekiq.yml")
  end
end
