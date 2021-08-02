class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :login_required

  def login_required
    redirect_to root_path unless logged_in?
  end
end
