class Admin::MenusController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features

	def index
	end

	def create
    if params[:event][:default_feature_icon] == "" or params[:event][:default_feature_icon].blank?
      @event.errors.add(:default_feature_icon, "This field is required.")
      render :action => 'index'
    else
      @event.errors.delete(:default_feature_icon)
      default_icon = params[:event][:default_feature_icon] rescue @event.default_feature_icon
      change = (@event.default_feature_icon != default_icon ) ? "true" : "false"
      @event.update(menu_saved: "true", default_feature_icon: default_icon)
      EventFeature.set_icon_to_feature(@event,default_icon,change)
      #########set feature as homepage changes ##########
      @homepage_feature_name = get_feature_name(event_params[:event_features_attributes])
      @home_page = @homepage_feature_name.map{|x|x[:status]}.count
      @active_feature = @homepage_feature_name.collect{|x|x[:status] if x[:status]=="active"}.compact.count
      @inactive_feature = @homepage_feature_name.collect{|x|x[:status] if x[:status]=="deactive"}.compact.count
      if @home_page == 1 && @event.update_attributes(event_params)#@home_page == 1 && @event.update_attributes(event_params)
        set_home_page_event_features(@homepage_feature_name)
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
      elsif @home_page > 1 and (@active_feature == 1 and @inactive_feature == 1)
        set_home_page_event_features(@homepage_feature_name)
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
      elsif @home_page > 1 and (@active_feature == 2 or @inactive_feature == 2)  
        @homepage_error = "You can set only one feature as home page feature" 
        render :action => 'index'
      elsif @event.update_attributes(event_params)
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
      else
        render :action => 'index'
      end
      ##############
      # if @event.update_attributes(event_params)
      #   redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
      # else
      #   render :action => 'index'
      # end
    end
	end

	def update
    @event.update_column(:menu_saved, "true")
    if params[:status].present?
      @event_feature.set_status(params[:status])
      redirect_to admin_event_menus_path(:event_id => @event.id)
    end
  end
  def show
    @images = ["abouts","agendas","awards","contacts","conversations","e_kits","exhibitors","faqs","favourites","feedbacks","galleries","invitees","my_calendar","my_network","my_profile","notes","polls","qnas","qr_code","quizzes","speakers","sponsors","venue"]
  end

  def destroy
    if @event_feature.destroy
      redirect_to admin_event_menus_path(:event_id => @event.id)
    end
  end
	protected

  def event_params
    params.require(:event).permit!
  end

  def get_feature_name(event_features)
    homepage_feature_name = []
    event_features.each do |name|
      if name.second["homepage_feature_name"].present?
        homepage_feature_name << {:status=>name.second["homepage_feature_name"],:title=>name.second["page_title"],:feature_id =>name.second["id"].to_i} 
      end
    end
    homepage_feature_name
  end

  def set_home_page_event_features(homepage_feature_name)
    homepage_feature_name.sort_by{|k| k[:status]}.reverse!.each do |feature|
      @home_feature = @event.event_features.where(id: feature[:feature_id]).first
      if feature[:status] == "deactive"
        @event.update_attributes(homepage_feature_name: nil, homepage_feature_id: nil)
      elsif feature[:status] == "active"
        @event.update_attributes(homepage_feature_name: @home_feature.name, homepage_feature_id: @home_feature.id)
      end
    end
  end 
   
end