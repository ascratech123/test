class Admin::ProhibitedAccessesController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user

  def index
    @prohibited_accesses = []
  end
end
