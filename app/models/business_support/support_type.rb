class BusinessSupport::SupportType
  include Mongoid::Document
  
  field :name, type: String
  field :slug, type: String
  index :slug 

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
