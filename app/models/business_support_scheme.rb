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

  scope :for_relations, ->(relations) {
    where({ "$and" => schemes_criteria(relations) }).asc(:title)
  }

  def self.schemes_criteria(relations)
    criteria = []
    relations.each do |k, v|
      collection = "business_support_#{k.to_s.singularize}_ids".to_sym
      collection_ids = ids_for_slugs(k, v)
      selector = { collection => [] }
      unless collection_ids.empty?
        selector = { "$or" => [{ collection => { "$in" => collection_ids } }, selector] }
      end
      criteria << selector
    end
    criteria 
  end

  def self.ids_for_slugs(key, slugs)
    klass = Kernel.const_get("BusinessSupport#{key.to_s.singularize.camelize}")
    klass.any_in(slug: slugs.split(',')).map(&:id)  
  end

end
