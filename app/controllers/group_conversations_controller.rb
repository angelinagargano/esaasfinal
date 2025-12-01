class GroupConversationsController < ApplicationController
  before_action :require_login
  before_action :set_group
  
  def show
    unless @group.member?(current_user)
      flash[:alert] = "You must be a member of this group to view messages."
      redirect_to groups_path and return
    end
    
    # The group should already have a conversation via after_create callback
    # But we'll handle the case where it might not exist
    @group_conversation = @group.group_conversation || GroupConversation.create!(group: @group, name: @group.name)
    @messages = @group_conversation.group_messages.includes(:sender, :events).order(created_at: :asc)
    @new_message = GroupMessage.new
  end
  
  private
  
  def set_group
    @group = Group.find(params[:group_id])
  end
end

