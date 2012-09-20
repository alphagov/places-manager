class BusinessSupportBusinessType
  include Mongoid::Document
  
  has_and_belongs_to_many :business_support_schemes, index: true
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  field :name, type: String 

end
