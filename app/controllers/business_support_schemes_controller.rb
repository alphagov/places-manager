class BusinessSupportSchemesController < ApplicationController

  RELATIONAL_KEYS = [:business_types, :sectors, :stages, :locations, :types]

  def index
    criteria = schemes_criteria
    if criteria.empty?
      schemes = BusinessSupportScheme.asc(:title)
    else
      relations = params.keep_if{ |k,v| RELATIONAL_KEYS.include?(k.to_sym) }
      schemes = BusinessSupportScheme.where({ "$and" => schemes_criteria }).asc(:title)
    end 
    @count = schemes.size
    @schemes_json = schemes.to_json(only: [:business_support_identifier, :title]) 
    respond_to do |format|
      format.json
    end
  end

  private

  def schemes_criteria
    criteria = []
    RELATIONAL_KEYS.each do |sym|
      unless params[sym].nil?
        collection = "business_support_#{sym.to_s.singularize}_ids".to_sym
        collection_ids = ids_for_slugs(sym)
        selector = { collection => [] }
        unless collection_ids.empty?
          selector = { "$or" => [{ collection => { "$in" => collection_ids } }, selector] }
        end
        criteria << selector
      end
    end
    criteria
  end

  def ids_for_slugs(sym)
    klass = Kernel.const_get("BusinessSupport#{sym.to_s.singularize.camelize}")
    klass.any_in(slug: params[sym].split(',')).map(&:id)  
  end
end
