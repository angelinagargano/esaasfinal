class GroupsController < ApplicationController
  before_action :require_login
  before_action :set_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]
  
  def index
    @groups = current_user.groups.includes(:creator, :members)
    @groups_created = current_user.groups_created.includes(:members)
  end
  
  def show
    @members = @group.members.includes(:friendships, :inverse_friendships)
    @group_conversation = @group.group_conversation
    @available_friends = current_user.all_friends - @group.members - [current_user]
  end
  
  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(group_params)
    @group.creator = current_user
    
    if @group.save
      # Add creator as admin member
      @group.group_members.create!(user: current_user, role: 'admin')
      flash[:notice] = "Group created successfully!"
      redirect_to group_path(@group)
    else
      flash[:alert] = @group.errors.full_messages.join(', ')
      render :new
    end
  end
  
  def edit
    return unless authorize_group_admin
  end
  
  def update
    return unless authorize_group_admin
    
    if @group.update(group_params)
      flash[:notice] = "Group updated successfully!"
      redirect_to group_path(@group)
    else
      flash[:alert] = @group.errors.full_messages.join(', ')
      render :edit
    end
  end
  
  def destroy
    return unless authorize_group_admin
    @group.destroy
    flash[:notice] = "Group deleted successfully!"
    redirect_to groups_path
  end
  
  def add_member
    return unless authorize_group_admin
    
    friend_id = params[:friend_id]
    friend = User.find(friend_id)
    
    # Verify they are friends
    unless current_user.all_friends.include?(friend)
      flash[:alert] = "You can only add friends to groups."
      redirect_to group_path(@group) and return
    end
    
    member = @group.group_members.build(user: friend)
    if member.save
      flash[:notice] = "#{friend.username} added to group."
    else
      flash[:alert] = "Unable to add member."
    end
    
    redirect_to group_path(@group)
  end
  
  def remove_member
    return unless authorize_group_admin
    
    member = @group.group_members.find_by(user_id: params[:user_id])
    if member && member.user != current_user
      member.destroy
      flash[:notice] = "Member removed from group."
    else
      flash[:alert] = "Unable to remove member."
    end
    
    redirect_to group_path(@group)
  end
  
  private
  
  def set_group
    @group = Group.find(params[:id])
  end
  
  def group_params
    params.require(:group).permit(:name, :description)
  end
  
  def authorize_group_admin
    unless @group.admin?(current_user)
      flash[:alert] = "You don't have permission to perform this action."
      redirect_to group_path(@group)
      return false
    end
    true
  end
end

