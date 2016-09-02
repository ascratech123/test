class Admin::QrCodeScannersController < ApplicationController
  layout 'admin/layouts/scanner'

  skip_before_filter :authenticate_user!
  skip_before_filter :load_filter
  before_filter :authorize_event_role

  def index
    if params[:page].present? && params[:page]=="print_preview"
      invitee_registration = Invitee.find_by_id(params[:invitee_id])
      invitee_registration.update_column('qr_code_registration',true) if invitee_registration.present?
    end  
    @invitee = @event.invitees.where(:id => params[:invitee_id]).last
    @invitees = @event.invitees.where('email like ? or name_of_the_invitee like ?', "%#{params[:email]}%", "%#{params[:email]}%") if params[:email].present?
  end

  def show
    @invitee = @event.invitees.find_by_id(params[:id])
    @invitee.update_column('qr_code_registration',true)
    respond_to do |format|
      message = @invitee.present? ? "valid" : 'invalid'
      # format.js{render :js => "window.location.href = #{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'thank_you', :meassge => message)}" }
      invitee_id = @invitee.id rescue ''
      format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'thank_you', :qr_code_preview => 'true', :meassge => message, :invitee_id => invitee_id)}'" }
      format.html
    end
  end

  protected

  def authorize_event_role
    @event = Event.find_by_id(params[:event_id])
    if @event.blank?
      redirect_to admin_dashboards_path
    end
  end

end