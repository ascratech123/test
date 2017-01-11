class Admin::UnsubscribesController < ApplicationController
  skip_before_filter :authenticate_user, :load_filter

  def show
    
  end
end
