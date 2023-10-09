class AlterPlacesChangeSnacToGss < ActiveRecord::Migration[7.0]
  def change
    rename_column :place_archives, :snac, :gss
    rename_column :places, :snac, :gss
  end
end
