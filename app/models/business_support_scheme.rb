class BusinessSupportScheme
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  
  field :title, type: String
  field :business_support_identifier, type: String
  field :priority, type: Integer, default: 1

  field :business_types,  type: Array, default: []
  field :locations,       type: Array, default: []
  field :purposes,        type: Array, default: []
  field :sectors,         type: Array, default: []
  field :stages,          type: Array, default: []
  field :support_types,   type: Array, default: []
  field :start_date,      type: Date
  field :end_date,        type: Date


  index :title, unique: true
  index :business_support_identifier, unique: true
  index :locations

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
      slugs = v.split(",")
      criteria << { collection => { "$in" => slugs } } unless slugs.empty?
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

  def active?
    has_started? && !has_ended?
  end

  private

  def has_started?
    # if start date is nil, it has been started since beginning of time
    self.start_date.nil? || (self.start_date <= Date.today)
  end

  def has_ended?
    self.end_date.present? && (self.end_date <= Date.today)
  end

end
