class Admin::InviteesController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role#, :find_features
  before_filter :find_features, if: :not_qr_code_scan?
  before_filter :find_invitee, if: :qr_code_scan?

  

  def index
    if params["send_mail"] == "true"
      invitees = @invitees.where("email_send !=?", "true")
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
        only_columns = [:first_name, :last_name, :email, :designation, :company_name, :invitee_status]
        method_allowed = []
        send_data @invitees.to_xls(:only => only_columns, :filename => "asd.xls")
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
        message = @invitee.present? ? "valid" : 'invalid'
        # format.js{render :js => "window.location.href = #{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'thank_you', :meassge => message)}" }
        invitee_id = @invitee.id rescue ''
        format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'thank_you', :meassge => message, :invitee_id => invitee_id)}'" }
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

  def not_qr_code_scan?
    !(params[:format].present? and params[:format] == 'js')
  end

  def qr_code_scan?
    (params[:format].present? and params[:format] == 'js')
  end

  def find_invitee
    @invitee = @event.invitees.where(:id => params[:id]).last
  end
end