class CreateActions < ActiveRecord::Migration[7.0]
  def change
    create_table :actions do |t|
      t.belongs_to    :data_set
      t.integer       :requester_id
      t.integer       :approver_id
      t.datetime      :approved
      t.string        :comment   # How long?
      t.string        :request_type   # How long?
      t.timestamps
    end
  end
end
