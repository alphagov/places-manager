class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.string :name
      t.string :slug, index: { unique: true }
      t.integer :active_data_set_version, default: 1
      t.string :source_of_data
      t.string :location_match_type, default: "nearest"
      t.string :local_authority_hierarchy_match_type, default: "district"
      t.timestamps
    end
  end
end
