require 'rails_helper'

RSpec.describe GroupMessagesController, type: :controller do
  let(:creator) do
    User.create!(
      email: 'creator@example.com',
      name: 'Creator',
      username: 'creator',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:group) { Group.create!(name: "Test Group", creator: creator) }
  let(:event) { Event.create!(name: "Test Event", date: "2024-01-01", time: "19:00", venue: "Test Venue", location: "Test Location") }

  before do
    session[:user_id] = creator.id
  end

  describe 'POST #create' do
    it 'creates a group message' do
      expect {
        post :create, params: { group_id: group.id, group_message: { content: "Hello" } }
      }.to change(GroupMessage, :count).by(1)
    end

    it 'creates message with events' do
      expect {
        post :create, params: { 
          group_id: group.id, 
          group_message: { content: "Check this out" },
          event_ids: [event.id]
        }
      }.to change(GroupMessageEvent, :count).by(1)
    end

    it 'prevents non-members from sending messages' do
      user2 = User.create!(email: 'user2@example.com', name: 'User Two', username: 'user2', password: 'password123', password_confirmation: 'password123')
      session[:user_id] = user2.id
      post :create, params: { group_id: group.id, group_message: { content: "Hello" } }
      expect(flash[:alert]).to be_present
    end

    it 'handles validation errors on create' do
      # Create message without content and without events
      post :create, params: { group_id: group.id, group_message: { content: "" } }
      expect(flash[:alert]).to be_present
      expect(response).to render_template('group_conversations/show')
    end
  end
end

