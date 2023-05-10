class AddIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :data_sets, %i[service_id version]
    add_index :places, %i[service_slug data_set_version]
  end
end
