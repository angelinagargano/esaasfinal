require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user1) do
    User.create!(
      email: 'user1@example.com',
      name: 'User One',
      username: 'user1',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:user2) do
    User.create!(
      email: 'user2@example.com',
      name: 'User Two',
      username: 'user2',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:conversation) { Conversation.create!(user1: user1, user2: user2) }
  let(:event) { Event.create!(name: "Test Event", date: "2024-01-01", time: "19:00", venue: "Test Venue", location: "Test Location") }

  before do
    session[:user_id] = user1.id
  end

  describe 'POST #create' do
    it 'creates a message' do
      expect {
        post :create, params: { conversation_id: conversation.id, message: { content: "Hello" } }
      }.to change(Message, :count).by(1)
    end

    it 'creates message with events' do
      expect {
        post :create, params: { 
          conversation_id: conversation.id, 
          message: { content: "Check this out" },
          event_ids: [event.id]
        }
      }.to change(MessageEvent, :count).by(1)
    end

    it 'prevents access to other users conversations' do
      user3 = User.create!(email: 'user3@example.com', name: 'User Three', username: 'user3', password: 'password123', password_confirmation: 'password123')
      other_conv = Conversation.create!(user1: user2, user2: user3)
      post :create, params: { conversation_id: other_conv.id, message: { content: "Hello" } }
      expect(flash[:alert]).to be_present
    end

    it 'handles validation errors on create' do
      # Create message without content and without events
      post :create, params: { conversation_id: conversation.id, message: { content: "" } }
      expect(flash[:alert]).to be_present
      expect(response).to render_template('conversations/show')
    end
  end
end

