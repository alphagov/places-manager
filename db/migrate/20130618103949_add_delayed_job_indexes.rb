class AddDelayedJobIndexes < Mongoid::Migration
  def self.up
    return unless defined?(Delayed::Backend::Mongoid::Job)
    Delayed::Backend::Mongoid::Job.create_indexes
  end

  def self.down
  end
end
