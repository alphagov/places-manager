class DataSetsController < ApplicationController
  def show
    respond_to do |format|
      format.xml { render :xml => data_set }
      format.json { render :json => data_set }
    end
  end

  PUBLIC_BODIES = [
    "Attorney general's office",
    "Cabinet office",
    "Department for business, innovation and skills",
    "Department for communities and local government",
    "Department for culture, media and sport",
    "Department for education",
    "Department for environment, food and rural affairs",
    "Department for international development",
    "Department for transport",
    "Department for work and pensions",
    "Department of energy and climate change",
    "Department of health",
    "Foreign and commonwealth office",
    "HM treasury",
    "HM revenue & customs",
    "Home office",
    "Ministry of defence",
    "Ministry of justice",
    "Northern Ireland office",
    "Office of the advocate general for Scotland",
    "Office of the leader of the house of commons",
    "Privy council office",
    "Scotland office",
    "Wales office",
  ].freeze

  WRITING_TEAMS = [
  ].freeze

  def data_set
    return PUBLIC_BODIES if params[:id] == "public_bodies"
    return WRITING_TEAMS if params[:id] == "writing_teams"
  end
  hide_action :data_set
  private :data_set
end
