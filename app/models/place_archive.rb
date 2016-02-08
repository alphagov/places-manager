class PlaceArchive
  include Mongoid::Document

  field :service_slug, type: String
  field :data_set_version, type: Integer

  field :name,           type: String
  field :source_address, type: String
  field :address1,       type: String
  field :address2,       type: String
  field :town,           type: String
  field :postcode,       type: String
  field :access_notes,   type: String
  field :general_notes,  type: String
  field :url,            type: String
  field :email,          type: String
  field :phone,          type: String
  field :fax,            type: String
  field :text_phone,     type: String
  field :location,       type: Point
  field :override_lat,   type: Float
  field :override_lng,   type: Float
  field :geocode_error,  type: String
  field :snac,           type: String
end
