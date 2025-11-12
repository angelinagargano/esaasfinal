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

  # Show user profile
  def profile
    @user = current_user
    @liked_events = @user.liked_events.order(:date) || []
    # @going_events = @user.going_events_list.order(:date)  # Commented out - going_events table not created yet
  end

  # Show edit form
  def edit
    @user = current_user
  end

  # Update user information
  def update
    @user = current_user
    update_params = user_params
    
    # If password is blank, don't update it
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end
    
    if @user.update(update_params)
      #flash[:notice] = 'Your information was successfully updated.'
      #redirect_to "/users/#{@user.id}/profile"
      flash[:notice] = 'Your information was successfully updated.'
      redirect_to user_profile_path(@user.id)

      # Explicit path - this should definitely work
      #redirect_to "/users/#{@user.id}/profile" and return
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :edit
      #flash.now[:alert] = @user.errors.full_messages.join(', ')
      #render :edit
    end
  end

  def show
    redirect_to user_profile_path(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :username, :password, :password_confirmation)
  end
end
