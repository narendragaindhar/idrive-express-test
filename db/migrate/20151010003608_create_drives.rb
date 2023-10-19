class CreateDrives < ActiveRecord::Migration[5.2]
  def change
    create_table :drives do |t|
      t.string :identification_number
      t.string :serial
      t.boolean :active, null: false
      t.integer :size, limit: 8

      t.timestamps null: false
    end
  end
end
