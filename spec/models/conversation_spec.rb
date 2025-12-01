require 'rails_helper'

RSpec.describe Conversation, type: :model do
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

  let(:user3) do
    User.create!(
      email: 'user3@example.com',
      name: 'User Three',
      username: 'user3',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  describe 'associations' do
    it 'belongs to user1' do
      conversation = Conversation.new(user1: user1, user2: user2)
      expect(conversation.user1).to eq(user1)
    end

    it 'belongs to user2' do
      conversation = Conversation.new(user1: user1, user2: user2)
      expect(conversation.user2).to eq(user2)
    end

    it 'has many messages' do
      conversation = Conversation.create!(user1: user1, user2: user2)
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      expect(conversation.messages).to include(message)
    end

    it 'destroys messages when conversation is destroyed' do
      conversation = Conversation.create!(user1: user1, user2: user2)
      message = Message.create!(conversation: conversation, sender: user1, content: "Hello")
      conversation.destroy
      expect(Message.exists?(message.id)).to be false
    end
  end

  describe 'validations' do
    it 'validates uniqueness of user1_id scoped to user2_id' do
      Conversation.create!(user1: user1, user2: user2)
      duplicate = Conversation.new(user1: user1, user2: user2)
      expect(duplicate).not_to be_valid
    end

    it 'prevents creating conversation with yourself' do
      conversation = Conversation.new(user1: user1, user2: user1)
      expect(conversation).not_to be_valid
      expect(conversation.errors[:base]).to include("Cannot create conversation with yourself")
    end
  end

  describe 'scopes' do
    it 'for_user returns conversations where user is user1 or user2' do
      conv1 = Conversation.create!(user1: user1, user2: user2)
      conv2 = Conversation.create!(user1: user2, user2: user3)
      expect(Conversation.for_user(user1)).to include(conv1)
      expect(Conversation.for_user(user1)).not_to include(conv2)
    end

    it 'recent orders by last_message_at descending' do
      conv1 = Conversation.create!(user1: user1, user2: user2, last_message_at: 1.day.ago)
      conv2 = Conversation.create!(user1: user1, user2: user3, last_message_at: Time.current)
      expect(Conversation.recent.first).to eq(conv2)
    end
  end

  describe 'instance methods' do
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }

    it 'other_user returns the other participant' do
      expect(conversation.other_user(user1)).to eq(user2)
      expect(conversation.other_user(user2)).to eq(user1)
    end

    it 'participants returns both users' do
      expect(conversation.participants).to contain_exactly(user1, user2)
    end

    it 'unread_count_for returns count of unread messages' do
      Message.create!(conversation: conversation, sender: user2, content: "Hi", read: false)
      Message.create!(conversation: conversation, sender: user2, content: "Hello", read: true)
      expect(conversation.unread_count_for(user1)).to eq(1)
    end

    it 'mark_as_read_for marks all messages as read' do
      msg1 = Message.create!(conversation: conversation, sender: user2, content: "Hi", read: false)
      msg2 = Message.create!(conversation: conversation, sender: user2, content: "Hello", read: false)
      conversation.mark_as_read_for(user1)
      expect(msg1.reload.read).to be true
      expect(msg2.reload.read).to be true
    end

    it 'update_last_message_at! updates timestamp' do
      message = Message.create!(conversation: conversation, sender: user1, content: "Test")
      conversation.update_last_message_at!
      expect(conversation.reload.last_message_at).to be_within(1.second).of(message.created_at)
    end
  end
end

