module DelayedJobHelper
  def run_all_delayed_jobs
    Delayed::Worker.new(:exit_on_complete => true, :quiet => true).start
  end
end

World(DelayedJobHelper)
