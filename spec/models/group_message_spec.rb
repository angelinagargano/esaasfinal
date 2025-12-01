require 'rails_helper'

RSpec.describe GroupMessage, type: :model do
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
  let(:event) { Event.create!(name: "Test Event", date: "2024-01-01", time: "19:00", venue: "Test Venue", location: "Test Location") }

  describe 'associations' do
    it 'belongs to group_conversation' do
      message = GroupMessage.new(group_conversation: group_conversation, sender: creator, content: "Hello")
      expect(message.group_conversation).to eq(group_conversation)
    end

    it 'belongs to sender' do
      message = GroupMessage.new(group_conversation: group_conversation, sender: creator, content: "Hello")
      expect(message.sender).to eq(creator)
    end

    it 'has many group_message_events' do
      message = GroupMessage.create!(group_conversation: group_conversation, sender: creator, content: "Hello")
      gme = GroupMessageEvent.create!(group_message: message, event: event)
      expect(message.group_message_events).to include(gme)
    end

    it 'has many events through group_message_events' do
      message = GroupMessage.create!(group_conversation: group_conversation, sender: creator, content: "Hello")
      GroupMessageEvent.create!(group_message: message, event: event)
      expect(message.events).to include(event)
    end
  end

  describe 'validations' do
    it 'requires content if no events' do
      message = GroupMessage.new(group_conversation: group_conversation, sender: creator)
      expect(message).not_to be_valid
    end

    it 'allows message without content if it has events' do
      message = GroupMessage.new(group_conversation: group_conversation, sender: creator)
      message.group_message_events.build(event: event)
      expect(message).to be_valid
    end
  end

  describe 'instance methods' do
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
      GroupMember.create!(group: group, user: member, role: 'member')
    end

    it 'recipients returns all group members and creator' do
      message = GroupMessage.create!(group_conversation: group_conversation, sender: creator, content: "Hello")
      expect(message.recipients).to include(creator, member)
    end

    it 'has_events? returns true when message has events' do
      message = GroupMessage.create!(group_conversation: group_conversation, sender: creator, content: "Hello")
      GroupMessageEvent.create!(group_message: message, event: event)
      expect(message.has_events?).to be true
    end
  end
end

