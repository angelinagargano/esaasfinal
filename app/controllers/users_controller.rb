class UsersController < ApplicationController
  # Show sign up form
  def new
    @user = User.new
  end

  # Create a new user
  def create
    @user = User.new(user_params)
    if @user.save
      # After successful signup, log the user in and redirect to preferences
      session[:user_id] = @user.id
      session.delete(:preferences)  # Clear any existing preferences for new user
      flash[:notice] = 'Account created successfully! Please set your preferences.'
      redirect_to preferences_path and return
    else
      # Signup failed: show errors and render form again
      puts "User not saved! Errors: #{@user.errors.full_messages.inspect}"
      render :new and return
    end
  end

  # Show user profile
  def profile
    @user = current_user

    unless @user
      flash[:alert] = "Please log in first"
      redirect_to login_path and return
    end

    @liked_events = @user.liked_events.order(:date) || []
    @going_events = @user.going_events_list.order(:date) 
    # Friends: include both outgoing and incoming accepted friendships
    @friends = @user.all_friends

    # Pending requests
    @outgoing_pending = @user.friendships.where(status: false).includes(:friend).map(&:friend)
    @incoming_pending = @user.inverse_friendships.where(status: false).includes(:user).map(&:user)
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
      flash[:notice] = 'Your information was successfully updated.'
      redirect_to user_profile_path(@user.id)
    else
      render :edit
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
