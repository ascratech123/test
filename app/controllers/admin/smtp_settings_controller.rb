class Admin::SmtpSettingsController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user, :find_smtp_setting
  before_filter :set_back_url, :only => [:new,:edit]
  def index

  end

  def new
    if @smtp_setting.id.present?
      redirect_to edit_admin_smtp_setting_path(:id => @smtp_setting.id,:smtp_url => params[:smtp_url])
    else
      @smtp_setting = @licensee_admin.build_smtp_setting
    end  
  end

  def create
    @smtp_setting = SmtpSetting.new(smtp_setting_params)
    if @smtp_setting.save
      @url = session[:smtp_url]
      session[:smtp_url] = nil
      redirect_to (@url || "/")
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @smtp_setting.update_attributes(smtp_setting_params)
      @url = session[:smtp_url]
      session[:smtp_url] = nil
      redirect_to (@url || "/")
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @smtp_setting.destroy
      redirect_to new_admin_smtp_settings_path
    end
  end

  protected

  def find_smtp_setting
    @licensee_admin = current_user.get_licensee_admin
    @smtp_setting = @licensee_admin.smtp_setting
    @smtp_setting = @licensee_admin.build_smtp_setting if @smtp_setting.blank?
    redirect_to new_admin_smtp_setting_path if @smtp_setting.id.blank? and ['new', 'create'].exclude? params[:action]
  end

  def smtp_setting_params
    params.require(:smtp_setting).permit!
  end

  def set_back_url
    session[:smtp_url] = request.referer 
    @url = session[:smtp_url] 
  end
end
