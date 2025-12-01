class GroupMessageEvent < ApplicationRecord
  belongs_to :group_message
  belongs_to :event
  
  validates :event_id, uniqueness: { scope: :group_message_id }
end

