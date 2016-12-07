class Admin::LogChangesController < ApplicationController
	#before_filter :authenticate_user, :authorize_event_role, :find_features
	
	def update
		LogChange.create(:resourse_type => params[:resourse_type], :resourse_id => params[:id],:action => "destroy")
		record = params[:resourse_type].constantize.find(params[:id])
		record.update_column("last_force_destroyed",Time.now)
		redirect_to :back
	end
end
