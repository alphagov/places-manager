class RemoveBusinessStageFromSupportSchemes < Mongoid::Migration
  def self.up
    BusinessSupportScheme.all.each {|bss| bss.pull(:stages, 'exiting-a-business') }
  end

  def self.down
  end
end
