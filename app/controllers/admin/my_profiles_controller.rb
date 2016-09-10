class Admin::MyProfilesController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_action :set_my_profile_fields, :only => [:new, :edit, :update, :create]
  before_action :find_grouping_data, :only => [:index, :show]
  
  # def index
  #   if params[:format].present?
  #     respond_to do |format|
  #       format.html  
  #       format.xls do
  #         method_allowed = []
  #         for invitee in @invitee_datum
  #           arr = @only_columns.map{|c| invitee.attributes[c]}
  #           @export_array << arr
  #         end
  #         send_data @export_array.to_reports_xls
  #       end
  #     end
  #   else
  #     redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
  #   end
  # end

  def new
  end

  def create
    # @my_profile.set_enabled_attr(params)
    @my_profile = @event.my_profiles.build(my_profile_params)
    if @my_profile.save
      if params[:step].present? and params[:step] == 'two'
        redirect_to admin_event_mobile_application_path(:id => @event.mobile_application_id, :type => 'show_content')
      else
        redirect_to edit_admin_event_my_profile_path(:event_id => @event.id, :id => @my_profile.id, :step => 'two')
        # redirect_to admin_event_mobile_application_path(:id => @event.mobile_application_id, :type => 'show_content')
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @my_profile.set_enabled_attr(params)
    if @my_profile.save
      if params[:step].present? and params[:step] == 'two'
        redirect_to admin_event_mobile_application_path(:id => @event.mobile_application_id, :type => 'show_content')
      else
        redirect_to edit_admin_event_my_profile_path(:event_id => @event.id, :id => @my_profile.id, :step => 'two')
        # redirect_to admin_event_mobile_application_path(:id => @event.mobile_application_id, :type => 'show_content')
      end
    else
      render :action => "edit"
    end
  end

  def destroy
    if @my_profile.destroy
      redirect_to admin_event_invitee_structures_path(:event_id => @event.id)
    end
  end

  def show
    respond_to do |format|
      format.html  
      format.xls do
        method_allowed = []
        for invitee in @invitee_datum
          arr = @only_columns.map{|c| invitee.attributes[c]}
          @export_array << arr
        end
        send_data @export_array.to_reports_xls, filename: "#{@grouping.name.gsub(' ', '_') rescue 'Grouping'}.xls"
      end
    end
  end

  private

  def set_my_profile_fields
    @my_profile = MyProfile.get_my_profile(@event)
    @my_profile_attrs = MyProfile.get_default_grouping_fields(@event)
  end

  def my_profile_params
    params[:my_profile].permit!
  end

end
