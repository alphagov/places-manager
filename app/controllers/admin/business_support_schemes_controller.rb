class Admin::BusinessSupportSchemesController < InheritedResources::Base 
  include Admin::AdminControllerMixin
 
  actions :all, :only => [:index, :edit, :update]

  def index
    @schemes = BusinessSupportScheme.all
  end

  def edit
    @scheme = BusinessSupportScheme.find(params[:id])
  end

end
