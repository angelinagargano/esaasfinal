class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :venue
      t.string :date
      t.string :time
      t.string :style
      t.string :location
      t.string :price
      t.text :description
      t.string :tickets

      t.timestamps
    end
  end
end
