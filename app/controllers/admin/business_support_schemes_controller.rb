class Admin::BusinessSupportSchemesController < InheritedResources::Base 
  include Admin::AdminControllerMixin
 
  actions :all, :only => [:index, :edit, :update]

  before_filter :find_all_facets, :only => :edit

  def index
    @schemes = BusinessSupportScheme.asc(:title)
  end

  def edit
    @scheme = BusinessSupportScheme.find(params[:id])
  end

  def update
    @scheme = BusinessSupportScheme.find(params[:id])
    
  end

  def find_all_facets
    @sectors = BusinessSupportSector.asc(:name)
    @stages = BusinessSupportStage.asc(:name)
  end

end
