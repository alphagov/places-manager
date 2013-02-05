set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}
job_type :run_script, 'cd :path && /usr/local/bin/govuk_setenv imminence bundle exec script/:task :output'

every 15.minutes do
  run_script "geocoder"
end
