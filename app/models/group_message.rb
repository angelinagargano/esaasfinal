class GroupMessage < ApplicationRecord
  belongs_to :group_conversation
  belongs_to :sender, class_name: 'User'
  has_many :group_message_events, dependent: :destroy
  has_many :events, through: :group_message_events
  
  validates :content, presence: true, unless: -> { group_message_events.any? }
  validate :must_have_content_or_events
  
  scope :recent, -> { order(created_at: :desc) }
  
  def recipients
    group_conversation.group.members + [group_conversation.group.creator]
  end
  
  def has_events?
    group_message_events.any?
  end
  
  private
  
  def must_have_content_or_events
    if content.blank? && group_message_events.empty?
      errors.add(:base, "Message must have content or at least one event")
    end
  end
end

