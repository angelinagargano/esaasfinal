class Event < ActiveRecord::Base
    has_many :likes, dependent: :destroy
    has_many :liked_by_users, through: :likes, source: :user 
end
