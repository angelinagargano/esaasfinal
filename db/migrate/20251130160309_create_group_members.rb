class CreateGroupMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :group_members do |t|
      t.references :group, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.string :role, default: 'member'
      t.timestamps
    end
    
    add_index :group_members, [:group_id, :user_id], unique: true
  end
end

