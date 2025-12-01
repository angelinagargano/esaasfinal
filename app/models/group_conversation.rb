class GroupConversation < ApplicationRecord
  belongs_to :group
  has_many :group_messages, -> { order(created_at: :asc) }, dependent: :destroy
  
  validates :group_id, uniqueness: true
  
  def name
    super || group.name
  end
end

