class SetArchivedDataSetsState < Mongoid::Migration
  def self.up
    cbt_service = Service.where(slug: 'motorcycle-approved-training-bodies').first
    if cbt_service
      cbt_service.data_sets.map { |ds| ds.update_attribute(:state, 'archived') if ds.version < 114 }
    end

    number_plate_service = Service.where(slug: 'number-plate-supplier').first
    if number_plate_service
      number_plate_service.data_sets.map { |ds| ds.update_attribute(:state, 'archived') if ds.version < 18 }
    end
  end

  def self.down
  end
end
