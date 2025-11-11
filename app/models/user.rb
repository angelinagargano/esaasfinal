class User < ApplicationRecord
  has_secure_password
  has_many :likes, dependent: :destroy
  has_many :liked_events, through: :likes, source: :event

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end
