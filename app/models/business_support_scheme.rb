class BusinessSupportScheme
  include Mongoid::Document
  
  has_and_belongs_to_many :business_support_regions, index: true
  has_and_belongs_to_many :business_support_sectors, index: true
  has_and_belongs_to_many :business_support_stages, index: true
  has_and_belongs_to_many :business_support_types, index: true
  
  validates_uniqueness_of :title
  validates_uniqueness_of :business_support_identifier
  
  field :title, type: String
  field :business_support_identifier, type: String

end
