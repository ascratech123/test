class Admin::ChangeRolesController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  before_filter :check_roles_count

  def index
    
  end  

  def new
    
  end
  def create
    #return redirect_to :back if params[:role].blank?
    session[:current_user_role] = params[:role]
    params[:previous_url].include?("/users/sign_in") ? (redirect_to admin_dashboards_path) : (redirect_to params[:previous_url])
  end

  protected

  def check_roles_count
    if User.current.roles.pluck(:name).uniq.count <= 1
      session[:current_user_role] = User.current.roles.pluck(:name).uniq.first
      redirect_to admin_dashboards_path
    end
  end
end
