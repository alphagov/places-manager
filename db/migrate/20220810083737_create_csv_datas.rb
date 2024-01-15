class CreateCsvDatas < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_data do |t|
      t.string  :service_slug
      t.integer :data_set_version
      t.text    :data # 16 Mb?
      t.timestamps
    end
  end
end
