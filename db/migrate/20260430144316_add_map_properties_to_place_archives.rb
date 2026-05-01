class AddMapPropertiesToPlaceArchives < ActiveRecord::Migration[8.1]
  def change
    change_table :place_archives, bulk: true do |t|
      t.string :map_marker_symbol
      t.string :map_marker_colour
    end
  end
end
