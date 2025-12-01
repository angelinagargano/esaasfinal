require 'rails_helper'

RSpec.describe Message, type: :model do
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

  describe 'associations' do
    it 'belongs to conversation' do
      message = Message.new(conversation: conversation, sender: user1, content: "Hello")
      expect(message.conversation).to eq(conversation)
    end

    it 'belongs to sender' do
      message = Message.new(conversation: conversation, sender: user1, content: "Hello")
      expect(message.sender).to eq(user1)
    end

    it 'has many message_events' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      message_event = MessageEvent.create!(message: message, event: event)
      expect(message.message_events).to include(message_event)
    end

    it 'has many events through message_events' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      MessageEvent.create!(message: message, event: event)
      expect(message.events).to include(event)
    end
  end

  describe 'validations' do
    it 'requires content if no events' do
      message = Message.new(conversation: conversation, sender: user1)
      expect(message).not_to be_valid
    end

    it 'allows message without content if it has events' do
      message = Message.new(conversation: conversation, sender: user1)
      message.message_events.build(event: event)
      expect(message).to be_valid
    end

    it 'allows message with content and no events' do
      message = Message.new(conversation: conversation, sender: user1, content: "Hello")
      expect(message).to be_valid
    end
  end

  describe 'scopes' do
    it 'unread returns only unread messages' do
      msg1 = Message.create!(conversation: conversation, sender: user1, content: "Hi", read: false)
      msg2 = Message.create!(conversation: conversation, sender: user1, content: "Hello", read: true)
      expect(Message.unread).to include(msg1)
      expect(Message.unread).not_to include(msg2)
    end
  end

  describe 'instance methods' do
    it 'recipient returns the other user in conversation' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      expect(message.recipient).to eq(user2)
    end

    it 'mark_as_read! marks message as read' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello", read: false)
      message.mark_as_read!
      expect(message.reload.read).to be true
    end

    it 'has_events? returns true when message has events' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      MessageEvent.create!(message: message, event: event)
      expect(message.has_events?).to be true
    end

    it 'has_events? returns false when message has no events' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      expect(message.has_events?).to be false
    end
  end

  describe 'callbacks' do
    it 'updates conversation timestamp after creation' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      conversation.reload
      expect(conversation.last_message_at).to be_within(1.second).of(message.created_at)
    end
  end
end

