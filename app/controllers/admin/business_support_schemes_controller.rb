class Admin::BusinessSupportSchemesController < InheritedResources::Base 
  include Admin::AdminControllerMixin
 
  actions :all, :only => [:index, :edit, :update]

  before_filter :find_all_facets, :only => [:new, :edit]

  def index
    @schemes = BusinessSupportScheme.asc(:title)
    respond_to do |format|
      format.csv do
        send_data generate_schemes_csv(@schemes), :filename => 'business_support_schemes.csv'
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

protected

  def generate_schemes_csv(schemes)
    CSV.generate do |csv|
      csv << [
        "id","title",
        #"web_url","organiser","short description","body",
        #"eligibility","evaluation","additional information","contact details",
        #"max employees","min value","max value","continuation link",
        "business types","locations","purposes",
        "sectors","stages","support types",
      ]
      schemes.each do |scheme|
        csv << [
          scheme.business_support_identifier, scheme.title,
          # TODO: populate these fields from ContentAPI
          #nil, nil, nil, nil,
          #nil, nil, nil, nil,
          #nil, nil, nil, nil,
          scheme.business_types.join(','), scheme.locations.join(','), scheme.purposes.join(','),
          scheme.sectors.join(','), scheme.stages.join(','), scheme.support_types.join(','),
        ]
      end
    end
  end

  def find_all_facets
    @business_types = BusinessSupportBusinessType.asc(:name)
    @locations = BusinessSupportLocation.asc(:name)
    @purposes = BusinessSupportPurpose.asc(:name)
    @sectors = BusinessSupportSector.asc(:name)
    @stages = BusinessSupportStage.asc(:name)
    @types = BusinessSupportType.asc(:name)
  end
end
