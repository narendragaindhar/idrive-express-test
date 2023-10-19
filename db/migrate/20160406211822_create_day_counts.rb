class CreateDayCounts < ActiveRecord::Migration[5.2]
  def change
    create_table :day_counts do |t|
      t.references :order, index: true, foreign_key: true
      t.integer :count
      t.boolean :is_final

      t.timestamps null: false
    end
  end
end
