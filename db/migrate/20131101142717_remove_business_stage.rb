class RemoveBusinessStage < Mongoid::Migration
  def self.up
    return unless defined?(BusinessSupport) && defined?(BusinessSupport::Stage)

    BusinessSupport::Stage.where(slug: 'exiting-a-business').delete
  end

  def self.down
  end
end
