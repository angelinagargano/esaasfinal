require 'rails_helper'

RSpec.describe Friendship, type: :model do
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
    it 'belongs to a user' do
      friendship = Friendship.new(user: user1, friend: user2)
      expect(friendship.user).to eq(user1)
      expect(friendship.user_id).to eq(user1.id)
    end

    it 'belongs to a friend (User)' do
      friendship = Friendship.new(user: user1, friend: user2)
      expect(friendship.friend).to eq(user2)
      expect(friendship.friend_id).to eq(user2.id)
    end

    it 'destroys friendship when user is destroyed' do
      friendship = Friendship.create!(user: user1, friend: user2, status: false)
      user1.destroy
      expect(Friendship.exists?(friendship.id)).to be false
    end

    it 'destroys friendship when friend is destroyed' do
      friendship = Friendship.create!(user: user1, friend: user2, status: false)
      user2.destroy
      expect(Friendship.exists?(friendship.id)).to be false
    end
  end

  describe 'User model associations through Friendship' do
    describe 'user.friendships' do
      it 'returns friendships where user is the requester' do
        friendship = Friendship.create!(user: user1, friend: user2, status: false)
        expect(user1.friendships).to include(friendship)
        expect(user2.friendships).not_to include(friendship)
      end

      it 'returns multiple friendships for a user' do
        Friendship.create!(user: user1, friend: user2, status: false)
        Friendship.create!(user: user1, friend: user3, status: true)
        expect(user1.friendships.count).to eq(2)
      end
    end

    describe 'user.friends' do
      it 'returns friends through friendships' do
        Friendship.create!(user: user1, friend: user2, status: true)
        expect(user1.friends).to include(user2)
      end

      it 'does not include pending friendships' do
        Friendship.create!(user: user1, friend: user2, status: false)
        expect(user1.friends).not_to include(user2)
      end

      it 'returns multiple accepted friends' do
        Friendship.create!(user: user1, friend: user2, status: true)
        Friendship.create!(user: user1, friend: user3, status: true)
        expect(user1.friends.count).to eq(2)
        expect(user1.friends).to include(user2, user3)
      end
    end

    describe 'user.inverse_friendships' do
      it 'returns friendships where user is the friend (received requests)' do
        friendship = Friendship.create!(user: user1, friend: user2, status: false)
        expect(user2.inverse_friendships).to include(friendship)
        expect(user1.inverse_friendships).not_to include(friendship)
      end

      it 'returns multiple inverse friendships' do
        Friendship.create!(user: user1, friend: user2, status: false)
        Friendship.create!(user: user3, friend: user2, status: true)
        expect(user2.inverse_friendships.count).to eq(2)
      end
    end

    describe 'user.inverse_friends' do
      it 'returns users who sent friend requests to this user' do
        Friendship.create!(user: user1, friend: user2, status: true)
        expect(user2.inverse_friends).to include(user1)
      end

      it 'only includes accepted inverse friendships' do
        Friendship.create!(user: user1, friend: user2, status: false)
        expect(user2.inverse_friends).not_to include(user1)
        
        friendship = Friendship.find_by(user: user1, friend: user2)
        friendship.update!(status: true)
        user2.inverse_friends.reload
        expect(user2.inverse_friends).to include(user1)
      end
    end

    describe 'bidirectional friendship relationships' do
      it 'allows user1 to be friends with user2 and user2 to be friends with user1' do
        Friendship.create!(user: user1, friend: user2, status: true)
        Friendship.create!(user: user2, friend: user1, status: true)
        
        expect(user1.friends).to include(user2)
        expect(user2.friends).to include(user1)
        expect(Friendship.count).to eq(2)
      end

      it 'handles pending requests correctly' do
        # user1 sends request to user2
        Friendship.create!(user: user1, friend: user2, status: false)
        
        expect(user1.friends).not_to include(user2)
        expect(user2.inverse_friends).not_to include(user1)
        expect(user2.inverse_friendships.where(status: false)).to exist
      end
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      friendship = Friendship.new(user: user1, friend: user2, status: false)
      expect(friendship).to be_valid
    end

    it 'validates uniqueness of user_id scoped to friend_id' do
      Friendship.create!(user: user1, friend: user2, status: false)
      duplicate = Friendship.new(user: user1, friend: user2, status: true)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('has already been taken')
    end

    it 'allows same user_id with different friend_id' do
      Friendship.create!(user: user1, friend: user2, status: false)
      friendship2 = Friendship.new(user: user1, friend: user3, status: false)
      expect(friendship2).to be_valid
    end

    it 'allows same friend_id with different user_id' do
      Friendship.create!(user: user1, friend: user2, status: false)
      friendship2 = Friendship.new(user: user3, friend: user2, status: false)
      expect(friendship2).to be_valid
    end
  end

  describe 'status' do
    it 'defaults to false (pending)' do
      friendship = Friendship.create!(user: user1, friend: user2)
      expect(friendship.status).to be false
      expect(friendship.reload.status).to be false
    end

    it 'can be set to true (accepted)' do
      friendship = Friendship.create!(user: user1, friend: user2, status: true)
      expect(friendship.status).to be true
    end

    it 'can be updated from pending to accepted' do
      friendship = Friendship.create!(user: user1, friend: user2, status: false)
      friendship.update!(status: true)
      expect(friendship.status).to be true
      expect(user1.friends).to include(user2)
    end
  end
end
