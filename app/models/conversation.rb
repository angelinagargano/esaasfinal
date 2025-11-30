class Conversation < ApplicationRecord
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User'
  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy
  
  validates :user1_id, uniqueness: { scope: :user2_id }
  validate :users_must_be_different
  
  scope :for_user, ->(user) {
    where("user1_id = ? OR user2_id = ?", user.id, user.id)
  }
  
  scope :recent, -> { order(last_message_at: :desc) }
  
  def other_user(user)
    user == user1 ? user2 : user1
  end
  
  def participants
    [user1, user2]
  end
  
  def unread_count_for(user)
    messages.where.not(sender: user).where(read: false).count
  end
  
  def mark_as_read_for(user)
    messages.where.not(sender: user).where(read: false).update_all(read: true)
  end
  
  def update_last_message_at!
    update(last_message_at: messages.last&.created_at || Time.current)
  end
  
  private
  
  def users_must_be_different
    errors.add(:base, "Cannot create conversation with yourself") if user1_id == user2_id
  end
end

