class ConversationsController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: [:show, :destroy]
  
  def index
    @conversations = current_user.conversations.recent.includes(:user1, :user2, :messages)
    @unread_count = current_user.unread_messages_count
  end
  
  def show
    # Verify user is part of this conversation
    unless @conversation.participants.include?(current_user)
      flash[:alert] = "You don't have access to this conversation."
      redirect_to conversations_path and return
    end
    
    @messages = @conversation.messages.includes(:sender, :events).order(created_at: :asc)
    @other_user = @conversation.other_user(current_user)
    @new_message = Message.new
    
    # Mark messages as read
    @conversation.mark_as_read_for(current_user)
  end
  
  def create
    friend = User.find(params[:friend_id])
    
    # Verify they are friends
    unless current_user.all_friends.include?(friend)
      flash[:alert] = "You can only message your friends."
      redirect_back(fallback_location: user_profile_path(current_user)) and return
    end
    
    # Find or create conversation
    @conversation = Conversation.find_or_create_by(
      user1: [current_user, friend].min_by(&:id),
      user2: [current_user, friend].max_by(&:id)
    )
    
    redirect_to conversation_path(@conversation)
  end
  
  def destroy
    @conversation.destroy
    flash[:notice] = "Conversation deleted."
    redirect_to conversations_path
  end
  
  private
  
  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end

