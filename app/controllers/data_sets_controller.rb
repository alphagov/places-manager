class DataSetsController < ApplicationController
  def show
    respond_to do |format|
      # TODO: Provide other formats eg with to_xml
      format.json { render :json => data_set }
    end
  end

  PUBLIC_BODIES = [
    { :id => "Attorney general's office" },
    { :id => "Cabinet office" },
    { :id => "Department for business, innovation and skills" },
    { :id => "Department for communities and local government" },
    { :id => "Department for culture, media and sport" },
    { :id => "Department for education" },
    { :id => "Department for environment, food and rural affairs" },
    { :id => "Department for international development" },
    { :id => "Department for transport" },
    { :id => "Department for work and pensions" },
    { :id => "Department of energy and climate change" },
    { :id => "Department of health" },
    { :id => "Foreign and commonwealth office" },
    { :id => "HM treasury" },
    { :id => "HM revenue & customs" },
    { :id => "Home office" },
    { :id => "Ministry of defence" },
    { :id => "Ministry of justice" },
    { :id => "Northern Ireland office" },
    { :id => "Office of the advocate general for Scotland" },
    { :id => "Office of the leader of the house of commons" },
    { :id => "Privy council office" },
    { :id => "Scotland office" },
    { :id => "Wales office" },
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
