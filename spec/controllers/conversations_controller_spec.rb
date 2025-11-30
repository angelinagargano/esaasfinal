require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
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
    Friendship.create!(user: user1, friend: user2, status: true)
  end

  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns conversations' do
      conversation = Conversation.create!(user1: user1, user2: user2)
      get :index
      expect(assigns(:conversations)).to include(conversation)
    end
  end

  describe 'GET #show' do
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }

    it 'returns success' do
      get :show, params: { id: conversation.id }
      expect(response).to have_http_status(:success)
    end

    it 'prevents access to other users conversations' do
      user3 = User.create!(email: 'user3@example.com', name: 'User Three', username: 'user3', password: 'password123', password_confirmation: 'password123')
      other_conv = Conversation.create!(user1: user2, user2: user3)
      get :show, params: { id: other_conv.id }
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(conversations_path)
    end
  end

  describe 'POST #create' do
    it 'creates a conversation with a friend' do
      expect {
        post :create, params: { friend_id: user2.id }
      }.to change(Conversation, :count).by(1)
    end

    it 'prevents creating conversation with non-friend' do
      user3 = User.create!(email: 'user3@example.com', name: 'User Three', username: 'user3', password: 'password123', password_confirmation: 'password123')
      post :create, params: { friend_id: user3.id }
      expect(flash[:alert]).to eq("You can only message your friends.")
    end

    it 'finds existing conversation if it exists' do
      conversation = Conversation.create!(user1: user1, user2: user2)
      expect {
        post :create, params: { friend_id: user2.id }
      }.not_to change(Conversation, :count)
    end

    it 'handles invalid friend_id' do
      expect {
        post :create, params: { friend_id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'DELETE #destroy' do
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }

    it 'deletes the conversation' do
      delete :destroy, params: { id: conversation.id }
      expect(Conversation.exists?(conversation.id)).to be false
    end
  end
end

