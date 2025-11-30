class CreateGroupMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :group_messages do |t|
      t.references :group_conversation, foreign_key: true, null: false
      t.references :sender, foreign_key: { to_table: :users }, null: false
      t.text :content
      t.timestamps
    end
    
    add_index :group_messages, [:group_conversation_id, :created_at]
  end
end

