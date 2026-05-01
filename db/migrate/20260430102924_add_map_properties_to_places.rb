class AddMapPropertiesToPlaces < ActiveRecord::Migration[8.1]
  def change
    change_table :places, bulk: true do |t|
      t.string :map_marker_symbol
      t.string :map_marker_colour
    end
  end
end
