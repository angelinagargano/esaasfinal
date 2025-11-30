require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:creator) do
    User.create!(
      email: 'creator@example.com',
      name: 'Creator',
      username: 'creator',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:member) do
    User.create!(
      email: 'member@example.com',
      name: 'Member',
      username: 'member',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  before do
    session[:user_id] = creator.id
    Friendship.create!(user: creator, friend: member, status: true)
  end

  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    it 'returns success' do
      get :show, params: { id: group.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'creates a group' do
      expect {
        post :create, params: { group: { name: "New Group", description: "Test" } }
      }.to change(Group, :count).by(1)
    end

    it 'adds creator as admin member' do
      post :create, params: { group: { name: "New Group" } }
      group = Group.last
      expect(group.group_members.find_by(user: creator).role).to eq('admin')
    end

    it 'handles validation errors on create' do
      post :create, params: { group: { name: "AB" } } # Too short
      expect(flash[:alert]).to be_present
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    it 'returns success for admin' do
      get :edit, params: { id: group.id }
      expect(response).to have_http_status(:success)
    end

    it 'prevents non-admin from editing' do
      session[:user_id] = member.id
      GroupMember.create!(group: group, user: member, role: 'member')
      get :edit, params: { id: group.id }
      expect(flash[:alert]).to eq("You don't have permission to perform this action.")
      expect(response).to redirect_to(group_path(group))
    end
  end

  describe 'PATCH #update' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    it 'updates the group' do
      patch :update, params: { id: group.id, group: { name: "Updated Group", description: "New description" } }
      group.reload
      expect(group.name).to eq("Updated Group")
      expect(flash[:notice]).to eq("Group updated successfully!")
    end

    it 'handles validation errors on update' do
      patch :update, params: { id: group.id, group: { name: "AB" } } # Too short
      expect(flash[:alert]).to be_present
      expect(response).to render_template(:edit)
    end

    it 'prevents non-admin from updating' do
      session[:user_id] = member.id
      GroupMember.create!(group: group, user: member, role: 'member')
      patch :update, params: { id: group.id, group: { name: "Hacked" } }
      expect(flash[:alert]).to eq("You don't have permission to perform this action.")
    end
  end

  describe 'POST #add_member' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    it 'adds a friend to the group' do
      expect {
        post :add_member, params: { id: group.id, friend_id: member.id }
      }.to change(GroupMember, :count).by(1)
    end

    it 'prevents adding non-friends' do
      user3 = User.create!(email: 'user3@example.com', name: 'User Three', username: 'user3', password: 'password123', password_confirmation: 'password123')
      post :add_member, params: { id: group.id, friend_id: user3.id }
      expect(flash[:alert]).to eq("You can only add friends to groups.")
    end

    it 'handles failure when adding member fails' do
      # Create a duplicate member to trigger validation error
      GroupMember.create!(group: group, user: member, role: 'member')
      post :add_member, params: { id: group.id, friend_id: member.id }
      expect(flash[:alert]).to eq("Unable to add member.")
    end

    it 'prevents non-admin from adding members' do
      session[:user_id] = member.id
      GroupMember.create!(group: group, user: member, role: 'member')
      other_friend = User.create!(email: 'other@example.com', name: 'Other', username: 'other', password: 'password123', password_confirmation: 'password123')
      Friendship.create!(user: member, friend: other_friend, status: true)
      post :add_member, params: { id: group.id, friend_id: other_friend.id }
      expect(flash[:alert]).to eq("You don't have permission to perform this action.")
    end
  end

  describe 'DELETE #remove_member' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    before do
      GroupMember.create!(group: group, user: member, role: 'member')
    end

    it 'removes a member' do
      expect {
        delete :remove_member, params: { id: group.id, user_id: member.id }
      }.to change(GroupMember, :count).by(-1)
    end

    it 'handles removing non-existent member' do
      delete :remove_member, params: { id: group.id, user_id: 99999 }
      expect(flash[:alert]).to eq("Unable to remove member.")
    end

    it 'prevents removing yourself' do
      delete :remove_member, params: { id: group.id, user_id: creator.id }
      expect(flash[:alert]).to eq("Unable to remove member.")
    end

    it 'prevents non-admin from removing members' do
      session[:user_id] = member.id
      other_member = User.create!(email: 'other@example.com', name: 'Other', username: 'other', password: 'password123', password_confirmation: 'password123')
      GroupMember.create!(group: group, user: other_member, role: 'member')
      delete :remove_member, params: { id: group.id, user_id: other_member.id }
      expect(flash[:alert]).to eq("You don't have permission to perform this action.")
    end
  end

  describe 'DELETE #destroy' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    it 'deletes the group' do
      delete :destroy, params: { id: group.id }
      expect(Group.exists?(group.id)).to be false
    end

    it 'prevents non-admin from deleting group' do
      session[:user_id] = member.id
      GroupMember.create!(group: group, user: member, role: 'member')
      delete :destroy, params: { id: group.id }
      expect(flash[:alert]).to eq("You don't have permission to perform this action.")
      expect(Group.exists?(group.id)).to be true
    end
  end
end

