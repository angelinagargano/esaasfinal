class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  def current_user
    # Only run lookup if there's a user logged in (i.e., session[:user_id] set)
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  def logged_in?
    current_user.present?
  end
  
  def require_login
    unless logged_in?
      flash[:alert] = "Please log in first"
      redirect_to login_path
    end
  end
end
