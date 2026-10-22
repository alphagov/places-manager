class ModifyPlacesAddUid < ActiveRecord::Migration[8.1]
  def change
    change_table :places, bulk: true do |t|
      t.string :uid
    end

    change_table :place_archives, bulk: true do |t|
      t.string :uid
    end
  end
end
