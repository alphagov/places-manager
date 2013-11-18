class InitialiseArchiveState < Mongoid::Migration
  def self.up
    Service.all.each do |service|
      service.data_sets.update_all(state: 'unarchived')
    end
  end

  def self.down
  end
end
