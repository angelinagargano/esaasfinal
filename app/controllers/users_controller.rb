class UsersController < ApplicationController
  # Show sign up form
  def new
    @user = User.new
  end

  # Create a new user
  def create
    @user = User.new(user_params)
    if @user.save
      # After successful signup, redirect to the login page so the user can log in
      flash[:notice] = 'Account created. Please log in.'
      redirect_to login_path and return
    else
      # Signup failed: show errors and render form again
      puts "User not saved! Errors: #{@user.errors.full_messages.inspect}"
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :new and return
    end
  end

  private

  def user_params
    params.permit(:email, :name, :username, :password, :password_confirmation)
  end
end
