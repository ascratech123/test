class Admin::InviteesController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features, :except => [:autocomplete_invitee_name_of_the_invitee]
  
  autocomplete :invitee, :name_of_the_invitee, :full => true
  # admin_invitees_autocomplete_invitee_name_of_the_invitee_path

  def index
    if params["send_mail"] == "true"
      if @event.mobile_application.present? and @event.mobile_application.application_type == "multi event" 
        event_ids = @event.mobile_application.events.pluck(:id)
        invitees = []
        @invitees.each do |invitee|
          invitee1 = Invitee.where("event_id IN (?) AND email_send =? AND email =?", event_ids, "true", invitee.email).blank? ? invitee : nil
          invitees << invitee1
        end
        invitees = invitees.compact
      else 
        invitees = @invitees.where("email_send !=?", "true")
      end
      invitees.each do |invitee|
        UserMailer.send_password_invitees(invitee).deliver_now 
        invitee.update_column(:email_send, 'true')
      end
    end
    @invitees = Invitee.search(params, @invitees) if params[:search].present?
    @invitees = @invitees.paginate(page: params[:page], per_page: 10) if params["format"] != "xls"
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:email, :first_name, :last_name, :company_name,:designation, :country, :website, :invitee_status]
        method_allowed = [:city, :description, :phone_number,:facebook, :google_plus, :linkedin, :twitter, :logged_in] 
        send_data @invitees.to_xls(:only => only_columns,:methods => method_allowed, :filename => "asd.xls")
      end
    end
  end

  def new
    @invitee = @event.invitees.build
    @import = Import.new if params[:import].present?
  end

  def create
    @invitee = @event.invitees.build(invitee_params)
    if @invitee.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if params[:visible_status].present?
      @invitee.set_status(params[:visible_status])
      redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
    else
      if @invitee.update_attributes(invitee_params)
        redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
      else
        render :action => "edit"
      end
    end
  end

  def show
    if params["send_mail"] == "true"
      UserMailer.send_password_invitees(@invitee).deliver_now
      @invitee.update_column(:email_send, "true")
      redirect_to admin_event_invitees_path(:event_id => @event.id)
    else
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def destroy
    if @invitee.destroy
      redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
    end
  end

  protected

  def invitee_params
    params.require(:invitee).permit!
  end
end
