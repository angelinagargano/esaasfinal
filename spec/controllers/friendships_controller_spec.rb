require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
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

  before do
    session[:user_id] = user1.id
  end

  describe 'POST #create' do
    it 'creates a new friendship request' do
      post :create, params: { friend_id: user2.id }
      expect(Friendship.exists?(user: user1, friend: user2)).to be true
      expect(flash[:notice]).to eq("Friend request sent.")
      expect(response).to redirect_to(find_friends_search_path)
    end

    it 'prevents sending friend request to yourself' do
      post :create, params: { friend_id: user1.id }
      expect(flash[:alert]).to eq("Unable to send friend request.")
      expect(response).to redirect_to(find_friends_search_path)
    end

    it 'prevents duplicate friend requests' do
      Friendship.create!(user: user1, friend: user2, status: false)
      post :create, params: { friend_id: user2.id }
      expect(flash[:alert]).to eq("Unable to send friend request.")
    end

    it 'handles save failure gracefully' do
      allow_any_instance_of(Friendship).to receive(:save).and_return(false)
      post :create, params: { friend_id: user2.id }
      expect(flash[:alert]).to eq("Unable to send friend request.")
    end
  end

  describe 'POST #accept' do
    before do
      Friendship.create!(user: user2, friend: user1, status: false)
    end

    it 'accepts a friend request' do
      post :accept, params: { friend_id: user2.id }
      friendship = Friendship.find_by(user: user2, friend: user1)
      expect(friendship.status).to be true
      expect(flash[:notice]).to eq("Friend request accepted.")
      expect(response).to redirect_to(user_profile_path(user1))
    end

    it 'handles non-existent friendship' do
      post :accept, params: { friend_id: 99999 }
      expect(flash[:alert]).to eq("Unable to accept friend request.")
    end

    it 'handles update failure' do
      allow_any_instance_of(Friendship).to receive(:update).and_return(false)
      post :accept, params: { friend_id: user2.id }
      expect(flash[:alert]).to eq("Unable to accept friend request.")
    end
  end

  describe 'POST #reject' do
    before do
      Friendship.create!(user: user2, friend: user1, status: false)
    end

    it 'rejects a friend request' do
      expect {
        post :reject, params: { friend_id: user2.id }
      }.to change(Friendship, :count).by(-1)
      expect(flash[:notice]).to eq("Friend request rejected.")
      expect(response).to redirect_to(user_profile_path(user1))
    end

    it 'handles non-existent friendship' do
      post :reject, params: { friend_id: 99999 }
      expect(flash[:alert]).to eq("Unable to reject friend request.")
    end
  end

  describe 'DELETE #unfriend' do
    before do
      Friendship.create!(user: user1, friend: user2, status: true)
    end

    it 'unfriends a user (outgoing friendship)' do
      expect {
        delete :unfriend, params: { friend_id: user2.id }
      }.to change(Friendship, :count).by(-1)
      expect(flash[:notice]).to eq("Unfriended successfully.")
      expect(response).to redirect_to(user_profile_path(user1))
    end

    it 'unfriends a user (incoming friendship)' do
      Friendship.destroy_all
      Friendship.create!(user: user2, friend: user1, status: true)
      expect {
        delete :unfriend, params: { friend_id: user2.id }
      }.to change(Friendship, :count).by(-1)
      expect(flash[:notice]).to eq("Unfriended successfully.")
    end

    it 'handles non-existent friendship' do
      delete :unfriend, params: { friend_id: 99999 }
      expect(flash[:alert]).to eq("Unable to unfriend.")
    end
  end
end

