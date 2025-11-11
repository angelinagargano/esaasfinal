class User < ApplicationRecord
  has_secure_password
  has_many :likes, dependent: :destroy
  has_many :liked_events, through: :likes, source: :event
  has_many :going_events, dependent: :destroy
  has_many :going_events_list, through: :going_events, source: :event

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
end
