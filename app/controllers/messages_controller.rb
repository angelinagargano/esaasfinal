class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation
  
  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user
    
    # Verify user is part of conversation
    unless @conversation.participants.include?(current_user)
      flash[:alert] = "You don't have access to this conversation."
      redirect_to conversations_path and return
    end
    
    if @message.save
      # Handle event attachments
      if params[:event_ids].present?
        params[:event_ids].each do |event_id|
          @message.message_events.create(event_id: event_id)
        end
      end
      
      redirect_to conversation_path(@conversation), notice: "Message sent!"
    else
      @messages = @conversation.messages.includes(:sender, :events).order(created_at: :asc)
      @other_user = @conversation.other_user(current_user)
      @new_message = @message
      flash[:alert] = @message.errors.full_messages.join(', ')
      render 'conversations/show'
    end
  end
  
  private
  
  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end
  
  def message_params
    params.require(:message).permit(:content)
  end
end

