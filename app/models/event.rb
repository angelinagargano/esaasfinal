class Event < ActiveRecord::Base
    has_many :likes, dependent: :destroy
    has_many :liked_by_users, through: :likes, source: :user
    has_many :going_events, dependent: :destroy
    has_many :going_users, through: :going_events, source: :user
end
