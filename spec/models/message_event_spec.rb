require 'rails_helper'

RSpec.describe MessageEvent, type: :model do
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
  let(:message) { Message.create!(conversation: conversation, sender: user1, content: "Hello") }
  let(:event) { Event.create!(name: "Test Event", date: "2024-01-01", time: "19:00", venue: "Test Venue", location: "Test Location") }

  describe 'associations' do
    it 'belongs to message' do
      message_event = MessageEvent.new(message: message, event: event)
      expect(message_event.message).to eq(message)
    end

    it 'belongs to event' do
      message_event = MessageEvent.new(message: message, event: event)
      expect(message_event.event).to eq(event)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of event_id scoped to message_id' do
      MessageEvent.create!(message: message, event: event)
      duplicate = MessageEvent.new(message: message, event: event)
      expect(duplicate).not_to be_valid
    end
  end
end

