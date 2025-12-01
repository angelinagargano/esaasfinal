require 'rails_helper'

RSpec.describe User, type: :model do
  it 'validates presence of required fields' do
    user = User.new
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
    expect(user.errors[:name]).to include("can't be blank")
    expect(user.errors[:username]).to include("can't be blank")
    expect(user.errors[:password]).to include("can't be blank")
  end

  it 'enforces unique username' do
    User.create!(email: 'a@x.com', name: 'A', username: 'unique', password: 'password123', password_confirmation: 'password123')
    dup = User.new(email: 'b@x.com', name: 'B', username: 'unique', password: 'password234', password_confirmation: 'password234')
    expect(dup).not_to be_valid
    expect(dup.errors[:username]).to include('has already been taken')
  end

  describe 'messaging associations' do
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

    it 'has conversations_as_user1' do
      conversation = Conversation.create!(user1: user1, user2: user2)
      expect(user1.conversations_as_user1).to include(conversation)
    end

    it 'has conversations_as_user2' do
      conversation = Conversation.create!(user1: user2, user2: user1)
      expect(user1.conversations_as_user2).to include(conversation)
    end

    it 'conversations returns all conversations for user' do
      conv1 = Conversation.create!(user1: user1, user2: user2)
      conv2 = Conversation.create!(user1: user2, user2: user1)
      expect(user1.conversations).to include(conv1)
    end

    it 'unread_messages_count returns total unread count' do
      conversation = Conversation.create!(user1: user1, user2: user2)
      Message.create!(conversation: conversation, sender: user2, content: "Hi", read: false)
      Message.create!(conversation: conversation, sender: user2, content: "Hello", read: false)
      expect(user1.unread_messages_count).to eq(2)
    end
  end
end
