class BusinessSupportSchemesController < ApplicationController

  def index
    args = any_in_args
    if args.empty?
      schemes = BusinessSupportScheme.asc(:title)
    else
      schemes = BusinessSupportScheme.any_in(args).order_by(:title.asc)
    end 
    @count = schemes.size
    @schemes_json = schemes.to_json(only: [:business_support_identifier, :title]) 
    respond_to do |format|
      format.json
    end
  end

  private

  def any_in_args
    args = {}
    [:business_types, :sectors, :stages, :nations, :types].each do |sym|
      unless params[sym].nil?
        args["business_support_#{sym.to_s.singularize}_ids".to_sym] = ids_for_slugs(sym)
      end
    end
    args
  end
  
  def ids_for_slugs(sym)
    klass = Kernel.const_get("BusinessSupport#{sym.to_s.singularize.camelize}")
    klass.any_in(slug: params[sym].split(',')).map(&:id)  
  end
end
