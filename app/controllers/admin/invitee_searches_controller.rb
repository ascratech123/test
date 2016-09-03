class Admin::InviteeSearchesController < ApplicationController
  before_filter :find_event

  def index
    @invitees = @event.invitees
    @attendees = @event.invitees.unscoped.where(:qr_code_registration => true, :event_id => @event.id).order('updated_at desc')
    @attendance = @event.invitees.unscoped.where(:qr_code_registration => true, :event_id => @event.id).order('updated_at desc')
    # @comapny_names = @event.invitees.unscoped.where(:qr_code_registration => true, :event_id => @event.id).pluck(:company_name)
    @comapny_names = @event.invitees.unscoped.where("qr_code_registration = ? and event_id = ? and company_name != ?",true,@event.id,"").pluck(:company_name)


    @invitees = Invitee.search(params, @invitees) if params[:search].present? and ( params[:value].present? and params[:value] == "printBadge")
    @invitees = @invitees.paginate(page: params[:invitees_page], per_page: 10)
    
    @attendees = Invitee.search(params, @attendance) if (params[:search].present? and ( params[:value].present? and params[:value] == "attendee"))
    @attendees = @attendees.paginate(page: params[:attendees_page], per_page: 10)if params["format"] != "xls"
    
    respond_to do |format| 
      format.html  
      format.xls do
        only_columns = [:name_of_the_invitee, :company_name, :designation, :mobile_no, :email]
        send_data @attendees.to_xls(:only => only_columns, :filename => "asd.xls")
      end
    end
  end

  def new
    if @event.present? and @event.custom_page1s.present?
      redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id)
    else
      @custom_page1 = @event.custom_page1s.build
    end
  end

  def create
    @custom_page1 = @event.custom_page1s.build(custom_page_params)
    if @custom_page1.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      end
    else
      render :action => 'new'
    end
  end

  def edit
    # @custom_page1 = @event.custom_page1s.last
  end

  def update
    if @custom_page1.update_attributes(custom_page_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
    else
      render :action => "edit"
    end
  end

  def show
    #render html: @custom_page1.description.html_safe
    # respond_to do |format|
    #   format.html { render :show => @custom_page1.description.html_safe , :layout => false }
    # end
    render :layout => false
  end

  def destroy
    if @custom_page1.destroy
      redirect_to admin_event_custom_page1s_path(:event_id => @custom_page1.event_id)
    end
  end

  protected

  def find_event
    @event = Event.find_by_id(params[:event_id])  
  end

  def custom_page_params
    params.require(:custom_page1).permit!
  end
end
