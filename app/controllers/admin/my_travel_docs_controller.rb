class Admin::MyTravelDocsController < ApplicationController
  layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index,:new]

  def index
   
  end

  def new
    @my_travel_doc = @event.my_travel_docs.build
    #@import = Import.new if params[:import].present?
  end

  def create
    if params[:my_travel_attach_doc].present?
      errors = []
      params[:my_travel_attach_doc].each do |img|
        @my_travel_doc = @event.my_travel_docs.build(my_travel_attach_doc: img)
        @my_travel_doc.save
        if @my_travel_doc.errors.present?
          errors << "#{img.original_filename} #{@my_travel_doc.errors.messages[:my_travel_attach_doc].first}"
          @errors = errors
        end
      end
    end
    if @errors.present?
      render :action => 'new'
    else
      redirect_to admin_event_my_travels_path(:event_id => @event.id)
    # if @my_travel_doc.save
    #   redirect_to :back
    # else
    #   render :action => 'new'
    end
  end

  protected

  def my_travel_doc_params
    params.require(:my_travel_doc).permit!
  end

  def check_user_role
    if (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #(!current_user.has_role? :db_manager) 
      redirect_to admin_dashboards_path
    end  
  end

end
