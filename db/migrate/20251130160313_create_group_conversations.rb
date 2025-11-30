class CreateGroupConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :group_conversations do |t|
      t.references :group, foreign_key: true, null: false
      t.string :name
      t.timestamps
    end
  end
end

