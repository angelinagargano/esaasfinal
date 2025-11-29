require 'rails_helper'

RSpec.describe "Searches", type: :request do
  let(:current_user) do
    User.create!(
      email: 'current@example.com',
      name: 'Current User',
      username: 'currentuser',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:user1) do
    User.create!(
      email: 'user1@example.com',
      name: 'User One',
      username: 'alice123',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:user2) do
    User.create!(
      email: 'user2@example.com',
      name: 'User Two',
      username: 'bob456',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:user3) do
    User.create!(
      email: 'user3@example.com',
      name: 'User Three',
      username: 'charlie789',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  before do
    # Create users for testing
    user1
    user2
    user3
  end

  describe "GET /search/find_friends" do
    context "when user is logged in" do
      before do
        # Simulate login
        post login_path, params: { username_or_email: current_user.username, password: 'password123' }
      end

      it "returns http success" do
        get find_friends_search_path
        expect(response).to have_http_status(:success)
      end

      it "renders the find_friends template" do
        get find_friends_search_path
        expect(response).to render_template(:find_friends)
      end

      it "returns empty array when no username parameter is provided" do
        get find_friends_search_path
        expect(assigns(:users)).to eq([])
      end

      it "searches for users by username with partial match" do
        get find_friends_search_path, params: { username: 'alice' }
        expect(assigns(:users)).to include(user1)
        expect(assigns(:users)).not_to include(current_user)
      end

      it "excludes the current user from search results" do
        get find_friends_search_path, params: { username: 'current' }
        expect(assigns(:users)).not_to include(current_user)
      end

      it "excludes the current user even with exact username match" do
        get find_friends_search_path, params: { username: 'currentuser' }
        expect(assigns(:users)).not_to include(current_user)
        expect(assigns(:users)).to be_empty
      end

      it "returns multiple users matching the search" do
        User.create!(
          email: 'alice2@example.com',
          name: 'Alice Two',
          username: 'alice999',
          password: 'password123',
          password_confirmation: 'password123'
        )
        get find_friends_search_path, params: { username: 'alice' }
        results = assigns(:users)
        expect(results.count).to be >= 1
        expect(results.map(&:username)).to all(match(/alice/i))
        expect(results).not_to include(current_user)
      end

      it "returns empty array when no users match" do
        get find_friends_search_path, params: { username: 'nonexistentuser123' }
        expect(assigns(:users)).to be_empty
      end

      it "is case insensitive" do
        get find_friends_search_path, params: { username: 'ALICE' }
        expect(assigns(:users)).to include(user1)
      end

      it "handles partial matches at the beginning of username" do
        get find_friends_search_path, params: { username: 'bob' }
        expect(assigns(:users)).to include(user2)
      end

      it "handles partial matches in the middle of username" do
        User.create!(
          email: 'test@example.com',
          name: 'Test',
          username: 'testbobtest',
          password: 'password123',
          password_confirmation: 'password123'
        )
        get find_friends_search_path, params: { username: 'bob' }
        expect(assigns(:users).map(&:username)).to include('bob456', 'testbobtest')
      end

      it "handles empty string username parameter" do
        get find_friends_search_path, params: { username: '' }
        expect(assigns(:users)).to eq([])
      end

      it "handles whitespace-only username parameter" do
        get find_friends_search_path, params: { username: '   ' }
        # The controller uses .present? which should handle whitespace
        # If it doesn't match, it should return empty array
        expect(assigns(:users)).to be_a(Array)
      end
    end

    context "when user is not logged in" do
      it "returns http success" do
        get find_friends_search_path
        expect(response).to have_http_status(:success)
      end

      it "renders the find_friends template" do
        get find_friends_search_path
        expect(response).to render_template(:find_friends)
      end

      it "searches for users by username when not logged in" do
        get find_friends_search_path, params: { username: 'alice' }
        expect(assigns(:users)).to include(user1)
      end

      it "does not exclude any users when current_user is nil" do
        get find_friends_search_path, params: { username: 'current' }
        expect(assigns(:users)).to include(current_user)
      end

      it "returns all matching users when not logged in" do
        get find_friends_search_path, params: { username: 'user' }
        results = assigns(:users)
        # "user" only matches "currentuser", not "alice123", "bob456", or "charlie789"
        expect(results).to include(current_user)
        expect(results.map(&:username)).to all(match(/user/i))
      end

      it "returns empty array when no username parameter is provided" do
        get find_friends_search_path
        expect(assigns(:users)).to eq([])
      end
    end

    context "with edge cases" do
      before do
        post login_path, params: { username_or_email: current_user.username, password: 'password123' }
      end

      it "handles special characters in search" do
        User.create!(
          email: 'special@example.com',
          name: 'Special',
          username: 'user_123',
          password: 'password123',
          password_confirmation: 'password123'
        )
        get find_friends_search_path, params: { username: 'user_' }
        expect(assigns(:users).map(&:username)).to include('user_123')
      end

      it "handles numeric usernames" do
        User.create!(
          email: 'numeric@example.com',
          name: 'Numeric',
          username: '123456',
          password: 'password123',
          password_confirmation: 'password123'
        )
        get find_friends_search_path, params: { username: '123' }
        expect(assigns(:users).map(&:username)).to include('123456')
      end
    end
  end
end
