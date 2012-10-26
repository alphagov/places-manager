class BusinessSupportSchemesController < ApplicationController

  RELATIONAL_KEYS = [:business_types, :sectors, :stages, :locations, :types]

  def index
    relations = params.keep_if{ |k,v| RELATIONAL_KEYS.include?(k.to_sym) }
    if relations.empty?
      schemes = BusinessSupportScheme.asc(:title)
    else
      schemes = BusinessSupportScheme.for_relations(relations)
    end 
    @count = schemes.size
    @schemes_json = schemes.to_json(only: [:business_support_identifier, :title]) 
    respond_to do |format|
      format.json
    end
  end

end
