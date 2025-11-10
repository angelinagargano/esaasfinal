class AddBoroughToEvents < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:events, :borough)
      add_column :events, :borough, :string
    end
  end
end
