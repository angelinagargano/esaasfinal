require 'rails_helper'

RSpec.describe Group, type: :model do
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

  describe 'associations' do
    it 'belongs to creator' do
      group = Group.new(name: "Test Group", creator: creator)
      expect(group.creator).to eq(creator)
    end

    it 'has many group_members' do
      group = Group.create!(name: "Test Group", creator: creator)
      member_record = GroupMember.create!(group: group, user: member, role: 'member')
      expect(group.group_members).to include(member_record)
    end

    it 'has many members through group_members' do
      group = Group.create!(name: "Test Group", creator: creator)
      GroupMember.create!(group: group, user: member, role: 'member')
      expect(group.members).to include(member)
    end

    it 'has one group_conversation' do
      group = Group.create!(name: "Test Group", creator: creator)
      expect(group.group_conversation).to be_present
    end
  end

  describe 'validations' do
    it 'requires name' do
      group = Group.new(creator: creator)
      expect(group).not_to be_valid
    end

    it 'validates name length minimum' do
      group = Group.new(name: "AB", creator: creator)
      expect(group).not_to be_valid
    end

    it 'validates name length maximum' do
      group = Group.new(name: "A" * 51, creator: creator)
      expect(group).not_to be_valid
    end

    it 'validates description length maximum' do
      group = Group.new(name: "Test Group", description: "A" * 501, creator: creator)
      expect(group).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'creates group_conversation after creation' do
      group = Group.create!(name: "Test Group", creator: creator)
      expect(group.group_conversation).to be_present
      expect(group.group_conversation.group).to eq(group)
    end
  end

  describe 'instance methods' do
    let(:group) { Group.create!(name: "Test Group", creator: creator) }

    it 'admin? returns true for creator' do
      expect(group.admin?(creator)).to be true
    end

    it 'admin? returns true for admin members' do
      GroupMember.create!(group: group, user: member, role: 'admin')
      expect(group.admin?(member)).to be true
    end

    it 'admin? returns false for regular members' do
      GroupMember.create!(group: group, user: member, role: 'member')
      expect(group.admin?(member)).to be false
    end

    it 'member? returns true for creator' do
      expect(group.member?(creator)).to be true
    end

    it 'member? returns true for group members' do
      GroupMember.create!(group: group, user: member, role: 'member')
      expect(group.member?(member)).to be true
    end

    it 'member? returns false for non-members' do
      other_user = User.create!(email: 'other@example.com', name: 'Other', username: 'other', password: 'password123', password_confirmation: 'password123')
      expect(group.member?(other_user)).to be false
    end
  end
end

