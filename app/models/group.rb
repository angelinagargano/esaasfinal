class Group < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_one :group_conversation, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :description, length: { maximum: 500 }
  
  after_create :create_group_conversation
  
  def admin?(user)
    group_members.find_by(user: user)&.role == 'admin' || creator == user
  end
  
  def member?(user)
    group_members.exists?(user: user) || creator == user
  end
  
  private
  
  def create_group_conversation
    GroupConversation.create!(group: self, name: name)
  end
end

