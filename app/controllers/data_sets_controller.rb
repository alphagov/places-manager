class DataSetsController < ApplicationController
  def show
    respond_to do |format|
      # TODO: Provide other formats eg with to_xml
      format.json { render :json => data_set }
    end
  end

  PUBLIC_BODIES = [
    { :id => 1, :name => "Attorney General's Office" },
    { :id => 2, :name => "Cabinet Office" },
    { :id => 3, :name => "Department for Business, Innovation and Skills" },
    { :id => 4, :name => "Department for Communities and Local Government" },
    { :id => 5, :name => "Department for Culture, Media and Sport" },
    { :id => 6, :name => "Department for Education" },
    { :id => 7, :name => "Department for Environment, Food and Rural Affairs" },
    { :id => 8, :name => "Department for International Development" },
    { :id => 9, :name => "Department for Transport" },
    { :id => 10, :name => "Department for Work and Pensions" },
    { :id => 11, :name => "Department of Energy and Climate Change" },
    { :id => 12, :name => "Department of Health" },
    { :id => 13, :name => "Foreign & Commonwealth Office" },
    { :id => 14, :name => "HM Treasury" },
    { :id => 15, :name => "HM Revenue & Customs" },
    { :id => 16, :name => "Home Office" },
    { :id => 17, :name => "Ministry of Defence" },
    { :id => 18, :name => "Ministry of Justice" },
    { :id => 19, :name => "Northern Ireland Office" },
    { :id => 20, :name => "Office of the Advocate General for Scotland" },
    { :id => 21, :name => "Office of the Leader of the House of Commons" },
    { :id => 22, :name => "Privy Council Office" },
    { :id => 23, :name => "Scotland Office" },
    { :id => 24, :name => "Wales Office" },
    { :id => 25, :name => "Health & Safety Executive" },
    { :id => 26, :name => "UK Border Agency" },
    { :id => 27, :name => "Office of Fair Trading" },
    { :id => 28, :name => "Financial Services Authority" },
    { :id => 29, :name => "Driver & Vehicle Licencing Agency" },
    { :id => 30, :name => "Veterans Agency" },
    { :id => 31, :name => "Vehicle & Operator Services Agency" },
    { :id => 32, :name => "Driving Standards Agency" }
  ].sort_by { |body| body[:id] }.freeze

  WRITING_TEAMS = [
    { :id => 3,   :name => "BIS - Adult Education" },
    { :id => 4,   :name => "DCLG" },
    { :id => 11,  :name => "DWP - Benefits" },
    { :id => 18,  :name => "MoJ" },
    { :id => 169, :name => "GDS" },
    { :id => 170, :name => "DWP - Pensions, disabled and carers" },
    { :id => 177, :name => "BIS - Employment" }
  ].sort_by { |team| team[:id] }.freeze

  def data_set
    return PUBLIC_BODIES if params[:id] == "public_bodies"
    return WRITING_TEAMS if params[:id] == "writing_teams"
  end
  hide_action :data_set
  private :data_set
end
