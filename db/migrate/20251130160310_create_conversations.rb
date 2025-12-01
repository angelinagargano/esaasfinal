class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :user1, foreign_key: { to_table: :users }, null: false
      t.references :user2, foreign_key: { to_table: :users }, null: false
      t.datetime :last_message_at
      t.timestamps
    end
    
    add_index :conversations, [:user1_id, :user2_id], unique: true
    add_index :conversations, :last_message_at
  end
end

