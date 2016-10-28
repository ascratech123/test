class Admin::MarketingAppsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource# :except => [:create]
  before_filter :authenticate_user,:get_client
  # before_filter :authorize_client_role, :find_client_association
  # before_filter :check_moderator_role, :feature_redirect_on_condition, :only => [:index]


  def index
    @marketing_events = Event.where(:client_id => @client.id,:marketing_app => true)
    @marketing_events = @marketing_events.ordered.paginate(page: params[:page], per_page: 10)
  end

  protected
  def get_client
    if params[:client_id].present?
      @client = Client.find(params[:client_id])
    end
  end
end
