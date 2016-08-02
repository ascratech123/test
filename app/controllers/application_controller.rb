class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  before_action :load_filter, :check_licensee_expiry, :except => [:mobile_current_user]
  #before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_url_history, :except => :back
  before_action :set_current_user,:find_clients
  before_filter :telecaller_is_login
  #before_action :redirect_show_to_edit , :only => :show

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied!"
    redirect_to admin_dashboards_path
  end

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def load_filter
    if params[:key].present? 
      authenticate_user_from_token!
    elsif (params["controller"] == "api/v1/events" and params["key"].blank?)
      session['invitee_id'] = nil
    else
      session['invitee_id'] = nil  
      authenticate_user!
    end
  end

  def check_licensee_expiry
    if user_signed_in?
      licensee_admin = current_user.get_licensee_admin
      if licensee_admin.present?
        if licensee_admin.licensee_start_date.present? and licensee_admin.licensee_start_date > Date.today
          session[:licensee_expired] = 'Your account has been expired. Kindly connect with hobnob team'
          redirect_to admin_dashboards_path if params[:controller] != 'admin/dashboards' and request.env['REQUEST_METHOD'] == 'POST'
        elsif licensee_admin.licensee_end_date.present? and licensee_admin.licensee_end_date < Date.today
          session[:licensee_expired] = 'Your account has been expired. Kindly connect with hobnob team'
          redirect_to admin_dashboards_path if params[:controller] != 'admin/dashboards' and request.env['REQUEST_METHOD'] == 'POST'
        elsif session[:licensee_expired].present?
          session[:licensee_expired] = nil
        end
      end
    end
  end

  def set_current_user
    User.current = current_user
  end

  def authorize_client_role
    client_ids = Client.with_roles(current_user.roles.pluck(:name), current_user).pluck(:id)
    @events = Event.with_roles(current_user.roles.pluck(:name), current_user)
    client_ids += @events.pluck(:client_id)
    @clients = Client.where(:id => client_ids)
    @client = @clients.find_by_id(params[:client_id])
    return redirect_to admin_dashboards_path if @client.blank?
  
    @events = @events.where(:client_id => @client.id)
    @events = @client.events if @events.blank? and @client.present?
    @event = @events.find_by_id(params[:id]) if params[:id].present? and @events.present?

    @log_changes = LogChange.get_changes('Event', @event.id) if params[:id].present? and @event.present?
    
    if params[:id].present? and @event.blank? and params[:controller] == 'admin/events'
      redirect_to admin_dashboards_path
    end
  end

  def find_client_association
    features = params[:controller].gsub('admin/','')
    @events = Event.with_roles(current_user.roles.pluck(:name), current_user)
    @events = @events.where(:client_id => @client.id)
    if @events.blank?
      instance_variable_set("@"+features, @client.send(features)) if params[:action] == 'index'
    else
      instance_variable_set("@"+features, @events) if params[:action] == 'index'
    end
    ##Dont delete it #@attendee = @attendees.find_by_id(params[:id]) if params[:id].present? and @attendees.present?
    if @client.association(features).present? and params[:id].present?
      feature = @client.association(features).find(params[:id]) rescue nil
      instance_variable_set("@"+features.singularize, feature)
      instance_variable_set("@"+'log_changes', LogChange.get_changes(features.capitalize.singularize.camelize, feature.id)) if params[:action] == 'show'
    end
    redirect_to admin_dashboards_path if params[:id].present? and instance_variable_get("@"+features.singularize).blank?
  end

  def authorize_event_role
    @event = Event.find(params[:event_id]) rescue nil
    if @event.present?
      @assigned_event = Event.with_roles(current_user.roles.pluck(:name), current_user).where(:id => @event.id).first
      @client = Client.with_roles(current_user.roles.pluck(:name), current_user).where(:id => @event.client_id).first
      if (@client.blank? and @assigned_event.blank?)
        redirect_to admin_dashboards_path  
      end
    else
      redirect_to admin_dashboards_path
    end
  end

  def find_features
    #@attendees = @event.attendees
    features = params[:controller].gsub('admin/','')
    features = "event_features" if features == "menus"
    features = features.singularize if features == "mobile_applications" 
    features = features.singularize if features == "emergency_exits"
    instance_variable_set("@"+features, @event.send(features)) if params[:action] == 'index'
    
    ##Dont delete it #@attendee = @attendees.find_by_id(params[:id]) if params[:id].present? and @attendees.present?
    if @event.association(features).present? and params[:id].present?
      if features == "emergency_exit"
        feature = @event.emergency_exit rescue nil 
      else
        feature = @event.association(features).find(params[:id]) rescue nil 
      end
      instance_variable_set("@"+features.singularize, feature)
      
      instance_variable_set("@"+'log_changes', LogChange.get_changes(features.capitalize.singularize.camelize, feature.id)) if params[:action] == 'show'
      
    end
    #redirect_to '/404.html' if @attendees.blank?
    redirect_to admin_dashboards_path if params[:id].present? and instance_variable_get("@"+features.singularize).blank?
  end


  def authenticate_user
    unless (user_signed_in? and current_user.present?)
      unless user_signed_in? 
        redirect_to admin_dashboards_path
      end
    end  
  end

  def authenticate_super_admin
    unless (user_signed_in? and current_user.roles.present? and current_user.has_role? :super_admin)
     redirect_to admin_dashboards_path
    end
  end



  def after_sign_in_path_for(resource)
    if resource.roles.blank? #resource.has_role? :super_admin or resource.has_role? :licensee_admin
      admin_dashboards_path
    elsif resource.has_role? :super_admin
      admin_licensees_path
    elsif resource.has_role? :telecaller
      admin_event_telecaller_path(:event_id => resource.roles.second.resource_id,:id => resource.id)
    else
      admin_dashboards_path
    end
  end

  def set_url_history
    session[:skip_url_history] ||= false
    if session[:skip_url_history]
      session[:skip_url_history] = false
    else
      if ["create","update"].exclude?(params[:action]) 
        if (params["controller"] == "admin/clients" and params["action"] == "index"and params["client_id"] == "") or (params["controller"] == "admin/events" and params["action"] == "index"and params["event_id"] == "") or (params[:session_create] == "false")
        else
          session[:url_history] ||= []
          session[:url_history] << request.referrer unless session[:url_history].last == request.referrer
          session[:url_history].shift if session[:url_history].length == 10
        end  
      end
    end
    session[:url_history].compact if session[:url_history].present?
  end
 
  def back
    url = session[:url_history].pop
    session[:skip_url_history] = true
    redirect_to (url || "/")
  end
  
  def licensee_current_user
    if current_user.present? and current_user.has_role? :super_admin and session['licensee_user_id'].present?
      User.unscoped.find session['licensee_user_id']
    else
      current_user
    end
  end

  def find_clients
    if current_user.has_role? :super_admin
      @clients = Client.with_roles(current_user.roles.pluck(:name), current_user)
    else
      client_ids = Client.with_roles(current_user.roles.pluck(:name), current_user).pluck(:id)
      client_ids += Event.with_roles(current_user.roles.pluck(:name), current_user).pluck(:client_id)
      @clients = Client.where(:id => client_ids)
    end if current_user.present?
    @client = @clients.find(params[:id]) rescue nil if params[:id].present? and @clients.present?
    @log_changes = LogChange.get_changes('Client', @client.id) if params[:id].present? and @client.present?
    
    # if ['show', 'edit', 'destroy', 'update', 'manage_users'].include? params[:action] and @client.blank?
    #   redirect_to admin_clients_path
    # end
  end

  def telecaller_is_login
    if (current_user.present? and current_user.has_role? :telecaller) #and (params[:controller] != "admin/telecallers" and params[:action] != "show"))
    #   redirect_to destroy_user_session_path, :method => :get
    end #if (params[:controller] != "admin/invitee_datas" and params[:action] != "update")
  end

  protected

  def configure_permitted_parameters
  	#devise_parameter_sanitizer.for(:sign_up) << :first_name, :last_name, :username, :pin_code, :mobile, :role, :email, :password
  	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:first_name, :last_name, :username, :pin_code, :mobile, :email, :password, roles: []) }
  	devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:first_name, :last_name, :username, :pin_code, :mobile, :email, :current_password, :password, :password_confirmation, roles: []) }
  	#devise_parameter_sanitizer.for(:account_update) << :first_name, :last_name, :username, :pin_code, :mobile, :role, :email, :password
  end

  def authenticate_user_from_token!
    key = params[:key].presence
    user = key && Invitee.find_by_key(key)
    if user.nil?
      render :status=>401, :json=>{:status=>"Failure", :status_code => 401, :message=>"Invalid Key."}
      session['invitee_id'] = nil
      return
    end
    if user && Devise.secure_compare(user.authentication_token, params[:authentication_token]) && user.authentication_token.present?
      #sign_in user, store: true
      session['invitee_id'] = user.id
      user.update_column(:last_interation, Time.now)
    else
      render :status=>401, :json=>{:status=>"Failure", :status_code => 401, :message=>"Invalid Authentication token."}
      return
    end
  end

  def mobile_current_user
    Invitee.find_by_id(session['invitee_id'])
  end

  # def redirect_show_to_edit
  #   # if params[:action] == "show" and ["admin/events","admin/mobile_applications","admin/clients","admin/polls"].exclude?(params[:controller]) and params[:controller].split('/').first != 'api'
  #   #   redirect_controller = params[:controller].split("/").second
  #   #   url = "/admin/events/#{params[:event_id]}/#{redirect_controller}/#{params[:id]}/edit"
  #   #   url = "/admin/events/#{params[:event_id]}/awards/#{params[:award_id]}/winners/#{params[:id]}/edit"  if params[:controller] == "admin/winners"
  #   #   redirect_to url
  #   # end
  # end
end