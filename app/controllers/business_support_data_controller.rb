class BusinessSupportDataController < ApplicationController
  
  VALID_DATA_TYPES = ["business_type", "nation", "sector", "stage", "type"]
  
  def show
    respond_to do |format|
      format.json { render :json => data_set }
    end
  end

  private

  def data_set
    data_type = VALID_DATA_TYPES.include?(params[:id]) ? params[:id].capitalize : nil
    if data_type.nil?
      []
    else
      data_type_class = Kernel.const_get("BusinessSupport#{data_type}")
      data_type_class.all
    end
  end

end
