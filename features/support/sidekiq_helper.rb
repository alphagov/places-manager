require "govuk_sidekiq/testing"

module SidekiqHelper
  def run_all_delayed_jobs
    Sidekiq::Worker.drain_all
  end
end

World(SidekiqHelper)
