class AddGovukUrlAndGovukTitleToServices < ActiveRecord::Migration[7.1]
  def change
    change_table(:services, bulk: true) do |t|
      t.column :govuk_url, :string
      t.column :govuk_title, :string
    end
  end
end
