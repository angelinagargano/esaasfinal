class CreateGroupMessageEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :group_message_events do |t|
      t.references :group_message, foreign_key: true, null: false
      t.references :event, foreign_key: true, null: false
      t.timestamps
    end
    
    add_index :group_message_events, [:group_message_id, :event_id], unique: true
  end
end

