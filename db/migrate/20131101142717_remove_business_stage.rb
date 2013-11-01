class RemoveBusinessStage < Mongoid::Migration
  def self.up
    BusinessSupport::Stage.where(slug: 'exiting-a-business').delete
  end

  def self.down
  end
end
