class Admin::BusinessSupportSchemesController < InheritedResources::Base 
  include Admin::AdminControllerMixin
 
  actions :all, :only => [:index, :edit, :update]

  before_filter :find_all_facets, :only => [:new, :edit]

  def index
    @schemes = BusinessSupportScheme.asc(:title)
    respond_to do |format|
      format.csv do
        send_data BusinessSupportCSVPresenter.new(@schemes).to_csv, :filename => 'business_support_schemes.csv'
      end
      format.all
    end
  end

  def new
    @scheme = BusinessSupportScheme.new
  end

  def create
    @scheme = BusinessSupportScheme.new(params[:business_support_scheme])
    if @scheme.save
      redirect_to admin_business_support_schemes_path, 
        :notice => "#{@scheme.title} successfully created"
    else
      find_all_facets
      render :action => 'new'
    end
  end

  def edit
    @scheme = BusinessSupportScheme.find(params[:id])
  end

  def update
    @scheme = BusinessSupportScheme.find(params[:id])
    if @scheme.update_attributes(params[:business_support_scheme])
      redirect_to admin_business_support_schemes_path,
        :notice => "#{@scheme.title} successfully updated"
    else
      find_all_facets
      render :action => 'edit'
    end
  end

  def destroy
    begin
      scheme = BusinessSupportScheme.find(params[:id])
      if scheme.destroy
        flash_msg = { :notice => "#{scheme.title} successfully deleted" }
      else
        flash_msg = { :alert => "Failed to delete #{scheme.title}" }
      end

    rescue Mongoid::Errors::DocumentNotFound
      flash_msg = { :alert => "Document #{params[:id]} not found" }
    end
    redirect_to admin_business_support_schemes_path, flash_msg
  end

protected

  def find_all_facets
    @business_types = BusinessSupport::BusinessType.asc(:name)
    @business_sizes = BusinessSupport::BusinessSize.asc(:name)
    @locations = BusinessSupport::Location.asc(:name)
    @purposes = BusinessSupport::Purpose.asc(:name)
    @sectors = BusinessSupport::Sector.asc(:name)
    @stages = BusinessSupport::Stage.asc(:name)
    @types = BusinessSupport::SupportType.asc(:name)
  end
end
