class SessionsController < ApplicationController
  skip_before_action :login_required

  def create
    user = User.find_by(username: params[:username])
    error_message = "キャラクタ名またはパスワードが間違っています"
    if user.nil?
      flash[:danger] = error_message
    elsif user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "ログインしました"
    else
      flash[:danger] = error_message
    end

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
