class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, foreign_key: true, null: false
      t.references :sender, foreign_key: { to_table: :users }, null: false
      t.text :content
      t.boolean :read, default: false
      t.timestamps
    end
    
    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, [:sender_id, :read]
  end
end

