class CreateDataSets < ActiveRecord::Migration[7.0]
  def change
    create_table :data_sets do |t|
      t.belongs_to  :service
      t.integer     :version
      t.string      :change_notes
      t.string      :processing_error
      t.string      :state
      t.string      :archiving_error
      t.timestamps
    end
  end
end
