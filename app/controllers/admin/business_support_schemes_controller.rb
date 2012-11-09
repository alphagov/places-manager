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
    if @scheme.update_attributes(params[:business_support_scheme])
      redirect_to 'index'
    else
      find_all_facets
      render 'edit'
    end
  end

  def find_all_facets
    @business_types = BusinessSupportBusinessType.asc(:name)
    @locations = BusinessSupportLocation.asc(:name)
    @sectors = BusinessSupportSector.asc(:name)
    @stages = BusinessSupportStage.asc(:name)
    @types = BusinessSupportType.asc(:name)
  end

end
