class GroupMessagesController < ApplicationController
  before_action :require_login
  before_action :set_group_conversation
  
  def create
    @group = @group_conversation.group
    @message = @group_conversation.group_messages.build(group_message_params)
    @message.sender = current_user
    
    # Verify user is member of group
    unless @group.member?(current_user)
      flash[:alert] = "You must be a member of this group to send messages."
      redirect_to groups_path and return
    end
    
    if @message.save
      # Handle event attachments
      if params[:event_ids].present?
        params[:event_ids].each do |event_id|
          @message.group_message_events.create(event_id: event_id)
        end
      end
      
      redirect_to group_group_conversation_path(@group), notice: "Message sent!"
    else
      @group = @group_conversation.group
      @messages = @group_conversation.group_messages.includes(:sender, :events).order(created_at: :asc)
      @new_message = @message
      flash[:alert] = @message.errors.full_messages.join(', ')
      render 'group_conversations/show'
    end
  end
  
  private
  
  def set_group_conversation
    @group_conversation = Group.find(params[:group_id]).group_conversation || 
                          GroupConversation.create!(group: Group.find(params[:group_id]))
  end
  
  def group_message_params
    params.require(:group_message).permit(:content)
  end
end

