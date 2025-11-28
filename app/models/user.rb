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

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true

  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :password_confirmation, presence: true, if: -> { password.present? }
end
