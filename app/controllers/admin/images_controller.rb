class Admin::ImagesController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user, :authorize_event_role, :find_features
  
	def index
    @image = @event.images
	end

	def new
    @image = @event.images.build
    render "add_new"
	end

  def create
    #@image = @event.images.build
    #@image = @event.images.build(image_params)
    @image = @event.images.build(:image => params[:image][:image].first)
    if @image.save
      respond_to do |format|
        format.html {  
          render :json => { :files => [@image.to_jq_upload], 
          :content_type => 'text/html',
          :layout => false
         }
        }
        format.json {  
          render :json => {:files => [@image.to_jq_upload] }
        }
      end
    else 
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  def update
    #@image.update_attributes(image_params)
    redirect_to admin_event_images_path(:event_id => @event.id) 
  end

  def destroy
    @image.destroy
    redirect_to admin_event_images_path(:event_id => @event.id) 
  end

	protected

  def image_params
    params.require(:image).permit!
  end

end
