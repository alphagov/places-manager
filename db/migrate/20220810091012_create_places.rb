class CreatePlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :places do |t|
      t.string    :service_slug
      t.integer   :data_set_version
      t.string    :name
      t.string    :source_address
      t.string    :address1
      t.string    :address2
      t.string    :town
      t.string    :postcode
      t.string    :access_notes
      t.string    :general_notes
      t.string    :url
      t.string    :email
      t.string    :phone
      t.string    :fax
      t.string    :text_phone
      t.st_point  :location, geographic: true
      t.float     :override_lat
      t.float     :override_lng
      t.string    :geocode_error
      t.string    :snac
      t.timestamps
    end
  end
end
