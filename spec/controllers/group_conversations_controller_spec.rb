require 'rails_helper'

RSpec.describe GroupConversationsController, type: :controller do
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

  before do
    session[:user_id] = creator.id
  end

  describe 'GET #show' do
    it 'returns success' do
      get :show, params: { group_id: group.id }
      expect(response).to have_http_status(:success)
    end

    it 'prevents access for non-members' do
      user2 = User.create!(email: 'user2@example.com', name: 'User Two', username: 'user2', password: 'password123', password_confirmation: 'password123')
      session[:user_id] = user2.id
      get :show, params: { group_id: group.id }
      expect(flash[:alert]).to be_present
    end
  end
end

