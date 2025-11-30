class Event < ActiveRecord::Base
    has_many :likes, dependent: :destroy
    has_many :liked_by_users, through: :likes, source: :user
    has_many :going_events, dependent: :destroy
    has_many :going_users, through: :going_events, source: :user
    
    # Messaging associations
    has_many :message_events, dependent: :destroy
    has_many :messages, through: :message_events
    has_many :group_message_events, dependent: :destroy
    has_many :group_messages, through: :group_message_events
end
