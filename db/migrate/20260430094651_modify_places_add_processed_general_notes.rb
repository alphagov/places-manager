class ModifyPlacesAddProcessedGeneralNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :place_archives, :processed_general_notes, :string
    add_column :places, :processed_general_notes, :string
  end
end
