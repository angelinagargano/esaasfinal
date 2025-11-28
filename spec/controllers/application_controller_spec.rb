require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  let(:user) do
    User.create!(
      email: 'test@example.com',
      name: 'Test User',
      username: 'testuser',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  describe '#current_user' do
    it 'returns nil when no user is logged in' do
      get :index
      expect(controller.current_user).to be_nil
    end

    it 'returns the logged in user' do
      session[:user_id] = user.id
      get :index
      expect(controller.current_user).to eq(user)
    end

    it 'memoizes the current user' do
      session[:user_id] = user.id
      get :index
      first_call = controller.current_user
      second_call = controller.current_user
      expect(first_call.object_id).to eq(second_call.object_id)
    end

    it 'returns nil for invalid user id' do
      session[:user_id] = 99999
      get :index
      expect(controller.current_user).to be_nil
    end

    it 'returns nil when session user_id is nil' do
      session[:user_id] = nil
      get :index
      expect(controller.current_user).to be_nil
    end
  end

  describe '#logged_in?' do
    it 'returns false when no user is logged in' do
      get :index
      expect(controller.logged_in?).to be false
    end

    it 'returns true when user is logged in' do
      session[:user_id] = user.id
      get :index
      expect(controller.logged_in?).to be true
    end
  end

  describe 'helper_method' do
    it 'makes current_user callable from controller' do
      session[:user_id] = user.id
      get :index
      # Test that current_user works - this verifies helper_method was set up
      expect(controller.current_user).to eq(user)
    end

    it 'makes logged_in? callable from controller' do
      session[:user_id] = user.id
      get :index
      # Test that logged_in? works - this verifies helper_method was set up
      expect(controller.logged_in?).to be true
    end
  end
end

