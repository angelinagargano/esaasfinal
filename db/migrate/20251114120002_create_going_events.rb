class CreateGoingEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :going_events do |t|
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
