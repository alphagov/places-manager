class BusinessSupportSchemeController < ApplicationController
  def index 
    respond_to do |format|
      format.json { render :json => data_set }
    end
  end

  private

  def data_set
    args = all_in_args
    if args.empty?
      schemes = BusinessSupportScheme.all
    elsif params[:sectors].nil?
      schemes = BusinessSupportScheme.all_in(all_in_args)
    else
      schemes = BusinessSupportScheme.any_in(
        business_support_sector_ids: ids_for_slugs(:sectors)
      ).all_in(all_in_args)
    end
    schemes.to_json(only: [:title, :business_support_identifier])
  end

  def all_in_args
    args = {}
    [:business_types, :stages, :nations, :types].each do |sym|
      unless params[sym].nil?
        args["business_support_#{sym.to_s.singularize}_ids".to_sym] = ids_for_slugs(sym)
      end
    end
    args
  end
  
  def ids_for_slugs(sym)
    klass = Kernel.const_get("BusinessSupport#{sym.to_s.singularize.camelize}")
    klass.any_in(slug: params[sym]).map {|i| i.id.to_s}   
  end
end
