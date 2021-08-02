module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
    @current_user.ts_character.items # load inventory flags
    @current_user
  end

  def logged_in?
    session[:user_id]
  end
end