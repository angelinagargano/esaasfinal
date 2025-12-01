class CreateMessageEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :message_events do |t|
      t.references :message, foreign_key: true, null: false
      t.references :event, foreign_key: true, null: false
      t.timestamps
    end
    
    add_index :message_events, [:message_id, :event_id], unique: true
  end
end

