require 'rails_helper'

RSpec.describe GroupMessageEvent, type: :model do
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
  let(:group_conversation) { group.group_conversation }
  let(:group_message) { GroupMessage.create!(group_conversation: group_conversation, sender: creator, content: "Hello") }
  let(:event) { Event.create!(name: "Test Event", date: "2024-01-01", time: "19:00", venue: "Test Venue", location: "Test Location") }

  describe 'associations' do
    it 'belongs to group_message' do
      gme = GroupMessageEvent.new(group_message: group_message, event: event)
      expect(gme.group_message).to eq(group_message)
    end

    it 'belongs to event' do
      gme = GroupMessageEvent.new(group_message: group_message, event: event)
      expect(gme.event).to eq(event)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of event_id scoped to group_message_id' do
      GroupMessageEvent.create!(group_message: group_message, event: event)
      duplicate = GroupMessageEvent.new(group_message: group_message, event: event)
      expect(duplicate).not_to be_valid
    end
  end
end

