class DeleteLatestDataSetsForArchivedServices < Mongoid::Migration
  def self.up
    PlaceArchive.delete_all(
      conditions: {
        :service_slug => "motorcycle-approved-training-bodies",
        :data_set_version => {
          "$gte" => 114  }})

    PlaceArchive.delete_all(
      conditions: {
        :service_slug => "number-plate-supplier",
        :data_set_version => {
          "$gte" => 18  }})
  end

  def self.down
  end
end
