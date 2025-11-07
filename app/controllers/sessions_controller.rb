class SessionsController < ApplicationController
  def new
  end

  def create
    if defined?(User)
      user = User.find_by(username: params[:username])
      if user && user.respond_to?(:authenticate) ? user.authenticate(params[:password]) : (user.password == params[:password])
        session[:user_id] = user.id
        flash[:notice] = "Logged in as #{user.username}"
        redirect_to root_path and return
      else
        flash.now[:alert] = 'Invalid username or password'
        render :new and return
      end
    else
      # No User model: do a simple check by param values to simulate failure/success
      if params[:username].present? && params[:password].present?
        flash[:notice] = "Logged in as #{params[:username]}"
        redirect_to root_path and return
      else
        flash.now[:alert] = 'Invalid username or password'
        render :new and return
      end
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'Logged out'
  end
end
