class CreateOrdersDrives < ActiveRecord::Migration[6.1]
  def change
    create_table :orders_drives do |t|
      create_table :order_drives do |t|
        t.integer :drive_id
        t.integer :order_id
        t.timestamps
      end
  
      unless Rails.env.test? || ENV["CI"]
        add_foreign_key :order_drives, :drives, column: :drive_id
        add_foreign_key :order_drives, :orders, column: :order_id
      end
  
      add_index :order_drives, :drive_id
      add_index :order_drives, :order_id
    end
  end
end
