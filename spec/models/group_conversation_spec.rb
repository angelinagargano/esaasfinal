require 'rails_helper'

RSpec.describe GroupConversation, type: :model do
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

  describe 'associations' do
    it 'belongs to group' do
      expect(group.group_conversation.group).to eq(group)
    end

    it 'has many group_messages' do
      message = GroupMessage.create!(
        group_conversation: group.group_conversation,
        sender: creator,
        content: "Hello"
      )
      expect(group.group_conversation.group_messages).to include(message)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of group_id' do
      # Group already has a conversation created via callback
      duplicate = GroupConversation.new(group: group)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'name method' do
    it 'returns custom name if set' do
      # Update the existing conversation's name
      group.group_conversation.update!(name: "Custom Name")
      expect(group.group_conversation.name).to eq("Custom Name")
    end

    it 'returns group name if no custom name' do
      expect(group.group_conversation.name).to eq(group.name)
    end
  end
end

