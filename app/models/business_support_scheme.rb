class BusinessSupportScheme
  include Mongoid::Document
  
   
  field :title, type: String
  field :business_support_identifier, type: String
  field :priority, type: Integer, default: 1

  has_and_belongs_to_many :business_support_business_types, index: true
  has_and_belongs_to_many :business_support_locations, index: true
  has_and_belongs_to_many :business_support_sectors, index: true
  has_and_belongs_to_many :business_support_stages, index: true
  has_and_belongs_to_many :business_support_types, index: true

  field :business_types, type: Array, index: true
  field :locations, type: Array, index: true
  field :sectors, type: Array, index: true
  field :stages, type: Array, index: true
  field :support_types, type: Array, index: true

  validates_presence_of :title, :business_support_identifier
  validates_uniqueness_of :title
  validates_uniqueness_of :business_support_identifier
  validates_presence_of :priority
  validates_inclusion_of :priority, in: [0,1,2]

  before_validation :populate_business_support_identifier, :on => :create 

  scope :for_relations, lambda { |relations|
    where({ "$and" => schemes_criteria(relations) }).order_by([:priority, :desc], [:title, :asc])
  }

  def self.schemes_criteria(relations)
    criteria = []
    relations.each do |k, v|
      collection = "#{k.to_s.singularize}s".to_sym
      selector = { collection => [] }
      slugs = v.split(",")
      unless slugs.empty?
        selector = { "$or" => [{ collection => { "$in" => slugs } }, selector] }
      end
      criteria << selector
    end
    criteria 
  end

  def populate_business_support_identifier
    self.business_support_identifier ||= self.class.next_identifier
  end

  # TODO: This field originally stored a String identifier.
  # This was later changed to a numerical one, it would benefit from Integer field conversion.
  def self.next_identifier
    schemes = BusinessSupportScheme.all.sort do |a,b| 
      a.business_support_identifier.to_i <=> b.business_support_identifier.to_i
    end
    schemes.empty? ? 1 : schemes.last.business_support_identifier.to_i + 1
  end

end
