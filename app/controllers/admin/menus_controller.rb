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
      if @event.update_attributes(event_params)
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
      else
        render :action => 'index'
      end
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

end