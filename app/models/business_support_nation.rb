class BusinessSupportNation
  include Mongoid::Document

  has_and_belongs_to_many :business_support_schemes, index: true
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug

  field :name, type: String 
  field :slug, type: String
  index :slug
end
