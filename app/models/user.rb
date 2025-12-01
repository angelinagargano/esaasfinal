class User < ApplicationRecord
  has_secure_password validations: false

  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { status: true }) }, through: :friendships, source: :friend
  #received requests (someone sends the request to this user)
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, -> { where(friendships: { status: true }) }, through: :inverse_friendships, source: :user

  has_many :likes, dependent: :destroy
  has_many :liked_events, through: :likes, source: :event
  has_many :going_events, dependent: :destroy
  has_many :going_events_list, through: :going_events, source: :event

  # Messaging associations
  has_many :conversations_as_user1, class_name: 'Conversation', foreign_key: 'user1_id', dependent: :destroy
  has_many :conversations_as_user2, class_name: 'Conversation', foreign_key: 'user2_id', dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :group_messages_sent, class_name: 'GroupMessage', foreign_key: 'sender_id', dependent: :destroy
  
  # Groups associations
  has_many :groups_created, class_name: 'Group', foreign_key: 'creator_id', dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members

  def conversations
    Conversation.for_user(self).includes(:user1, :user2, :messages)
  end

  def unread_messages_count
    conversations.sum { |conv| conv.unread_count_for(self) }
  end

  # Get all friends (both outgoing and incoming accepted friendships)
  def all_friends
    accepted_outgoing = friendships.where(status: true).includes(:friend).map(&:friend)
    accepted_incoming = inverse_friendships.where(status: true).includes(:user).map(&:user)
    (accepted_outgoing + accepted_incoming).uniq
  end

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true

  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :password_confirmation, presence: true, if: -> { password.present? }
end
