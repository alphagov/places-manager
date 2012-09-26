class BusinessSupportScheme
  include Mongoid::Document
  
  has_and_belongs_to_many :business_support_business_types, index: true
  has_and_belongs_to_many :business_support_locations, index: true
  has_and_belongs_to_many :business_support_sectors, index: true
  has_and_belongs_to_many :business_support_stages, index: true
  has_and_belongs_to_many :business_support_types, index: true
   
  field :title, type: String
  field :business_support_identifier, type: String 

  validates_presence_of :title, :business_support_identifier
  validates_uniqueness_of :title
  validates_uniqueness_of :business_support_identifier
end
