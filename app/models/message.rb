class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  has_many :message_events, dependent: :destroy
  has_many :events, through: :message_events
  
  validates :content, presence: true, unless: -> { message_events.any? }
  validate :must_have_content_or_events
  
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  
  after_create :update_conversation_timestamp
  
  def recipient
    conversation.other_user(sender)
  end
  
  def mark_as_read!
    update(read: true)
  end
  
  def has_events?
    message_events.any?
  end
  
  private
  
  def update_conversation_timestamp
    conversation.update_last_message_at!
  end
  
  def must_have_content_or_events
    if content.blank? && message_events.empty?
      errors.add(:base, "Message must have content or at least one event")
    end
  end
end

