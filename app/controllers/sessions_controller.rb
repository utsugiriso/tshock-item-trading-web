class SessionsController < ApplicationController
  skip_before_action :login_required

  def create
    user = User.find_by!(username: params[:username])
    if user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "ログインしました"
    else
      flash[:danger] = "キャラクタ名またはパスワードが間違っています"
    end

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
