class Admin::ServicesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @services = Service.all
  end
  
  def new
    @service = Service.new
  end
  
  def show
    @service = Service.find(params[:id])
  end
end
