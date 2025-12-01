class SessionsController < ApplicationController
  # Show login form
  def new
  end

  # Handle login submission
  def create
    user = User.find_by(username: params[:username_or_email]) || User.find_by(email: params[:username_or_email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Logged in as #{user.username}"
      redirect_to performances_path and return
    else
      flash.now[:alert] = 'Invalid username or password'
      render :new and return
    end
  end

  # Handle logout
  def destroy
    session.delete(:user_id)
    flash[:notice] = 'Logged out'
    redirect_to root_path
  end
end
