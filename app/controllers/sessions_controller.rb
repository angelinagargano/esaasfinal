class SessionsController < ApplicationController
  def new
  end

  def create
    if defined?(User)
      user = User.find_by(username: params[:username])
      if user && user.respond_to?(:authenticate) ? user.authenticate(params[:password]) : (user.password == params[:password])
        session[:user_id] = user.id
        flash[:notice] = "Logged in as #{user.username}"
        redirect_to performances_path and return
      else
        flash.now[:alert] = 'Invalid username or password'
        render :new and return
      end
    else
      # No User model: consult in-memory stubbed users if present, otherwise reject
      if defined?($STUBBED_USERS) && $STUBBED_USERS[params[:username]] == params[:password]
        flash[:notice] = "Logged in as #{params[:username]}"
        redirect_to performances_path and return
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
