class CreateFriendships < ActiveRecord::Migration[8.0]
  def change
    create_table :friendships do |t|
      t.references :user, foreign_key: {to_table: :users}
      t.references :friend, foreign_key: {to_table: :users}
      t.boolean :status, default: false #false = pending, true = accepted

      t.timestamps
    end
  end
end
