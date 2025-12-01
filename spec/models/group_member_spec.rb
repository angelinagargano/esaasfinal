require 'rails_helper'

RSpec.describe GroupMember, type: :model do
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

  let(:group) { Group.create!(name: "Test Group", creator: creator) }

  describe 'associations' do
    it 'belongs to group' do
      group_member = GroupMember.new(group: group, user: member)
      expect(group_member.group).to eq(group)
    end

    it 'belongs to user' do
      group_member = GroupMember.new(group: group, user: member)
      expect(group_member.user).to eq(member)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of user_id scoped to group_id' do
      GroupMember.create!(group: group, user: member, role: 'member')
      duplicate = GroupMember.new(group: group, user: member, role: 'admin')
      expect(duplicate).not_to be_valid
    end

    it 'validates role inclusion' do
      group_member = GroupMember.new(group: group, user: member, role: 'invalid')
      expect(group_member).not_to be_valid
    end

    it 'allows admin role' do
      group_member = GroupMember.new(group: group, user: member, role: 'admin')
      expect(group_member).to be_valid
    end

    it 'allows member role' do
      group_member = GroupMember.new(group: group, user: member, role: 'member')
      expect(group_member).to be_valid
    end
  end
end

