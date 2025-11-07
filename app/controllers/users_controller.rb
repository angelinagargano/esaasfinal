class UsersController < ApplicationController
  # Show sign up form
  def new
    @user = User.new if defined?(User)
  end

  # Minimal create action: try to create a user if model exists, otherwise set flash and redirect
  def create
    if defined?(User)
      @user = User.new(user_params)
      if @user.save
        # After successful signup, redirect to the login page so the user can log in
        flash[:notice] = 'Account created. Please log in.'
        redirect_to login_path and return
      else
        flash.now[:alert] = @user.errors.full_messages.join(', ')
        render :new and return
      end
    else
      # No User model yet: just fake a successful signup if required fields present
      if params[:email].present? && params[:username].present? && params[:password].present?
        # store credentials in in-memory stub so the login fallback can validate
        $STUBBED_USERS ||= {}
        $STUBBED_USERS[params[:username]] = params[:password]
        flash[:notice] = 'Account created. Please log in.'
        redirect_to login_path and return
      else
        flash.now[:alert] = 'Please fill in all required fields.'
        render :new and return
      end
    end
  end

  private

  def user_params
    params.permit(:email, :name, :username, :password)
  end
end
