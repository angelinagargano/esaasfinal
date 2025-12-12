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

  it 'enforces unique email' do
    User.create!(email: 'test@example.com', name: 'A', username: 'user1', password: 'password123', password_confirmation: 'password123')
    dup = User.new(email: 'test@example.com', name: 'B', username: 'user2', password: 'password234', password_confirmation: 'password234')
    expect(dup).not_to be_valid
    expect(dup.errors[:email]).to include('has already been taken')
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

  describe 'recommendations associations' do
    let(:user) { User.create!(email: 'test@example.com', name: 'Test User', username: 'testuser', password: 'password123', password_confirmation: 'password123') }
    
    let!(:event1) { Event.create!(name: 'Event 1', style: 'Hip-hop', borough: 'Brooklyn', location: 'Location 1', date: '2025-01-15', time: '19:00', price: '$20', venue: 'Venue 1') }
    let!(:event2) { Event.create!(name: 'Event 2', style: 'Ballet', borough: 'Manhattan', location: 'Location 2', date: '2025-01-20', time: '18:00', price: '$50', venue: 'Venue 2') }
    let!(:event3) { Event.create!(name: 'Event 3', style: 'Contemporary', borough: 'Queens', location: 'Location 3', date: '2025-01-25', time: '20:00', price: '$30', venue: 'Venue 3') }

    it 'can have liked events' do
      user.liked_events << event1
      expect(user.liked_events).to include(event1)
    end

    it 'can have multiple liked events' do
      user.liked_events << event1
      user.liked_events << event2
      expect(user.liked_events.count).to eq(2)
      expect(user.liked_events).to include(event1, event2)
    end

    it 'can have going events' do
      GoingEvent.create!(user: user, event: event1)
      expect(user.going_events_list).to include(event1)
    end

    it 'can have multiple going events' do
      GoingEvent.create!(user: user, event: event1)
      GoingEvent.create!(user: user, event: event2)
      expect(user.going_events_list.count).to eq(2)
      expect(user.going_events_list).to include(event1, event2)
    end

    it 'can have both liked and going events' do
      user.liked_events << event1
      GoingEvent.create!(user: user, event: event2)
      
      expect(user.liked_events).to include(event1)
      expect(user.going_events_list).to include(event2)
    end

    it 'can have the same event as both liked and going' do
      user.liked_events << event1
      GoingEvent.create!(user: user, event: event1)
      
      expect(user.liked_events).to include(event1)
      expect(user.going_events_list).to include(event1)
    end

    it 'removes liked events when user is destroyed' do
      user.liked_events << event1
      expect { user.destroy }.to change { Like.count }.by(-1)
    end

    it 'removes going events when user is destroyed' do
      GoingEvent.create!(user: user, event: event1)
      expect { user.destroy }.to change { GoingEvent.count }.by(-1)
    end

    it 'does not remove events when user is destroyed' do
      user.liked_events << event1
      GoingEvent.create!(user: user, event: event2)
      
      expect { user.destroy }.not_to change { Event.count }
      expect(Event.exists?(event1.id)).to be true
      expect(Event.exists?(event2.id)).to be true
    end
  end
end