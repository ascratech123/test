class Admin::MicrositesController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  before_filter :find_event, :only => [:index, :new, :create, :edit]

  def index
    @event = Event.find(params[:event_id])
    @microsites = @event.microsites.paginate(page: params[:page], per_page: 10)
  end

  def new
    @event = Event.find(params[:event_id])
    @microsite = @event.microsites.build
  end

  def create
    @event = Event.find(params[:event_id])
    @microsite = @event.microsites.build(microsite_params)
    if @microsite.save
      redirect_to admin_event_microsites_path
    else
      render :action => 'new'
    end
  end

  def edit
    @microsite = Microsite.find(params[:id])
  end

  def update
    @microsite = Microsite.find(params[:id])
    if @microsite.update_attributes(microsite_params)
      redirect_to admin_event_microsites_path
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    @microsite = Microsite.find(params[:id])
    if @microsite.destroy
      redirect_to admin_event_microsites_path
    else
      admin_event_microsites_path
    end
  end

  protected
  
  def microsite_params
    params.require(:microsite).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end
end
