class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.belongs_to :customer, index: true, foreign_key: true
      t.integer :drive_id
      t.belongs_to :address, index: true, foreign_key: true
      t.belongs_to :datacenter, index: true, foreign_key: true
      t.belongs_to :express_kind, index: true, foreign_key: true
      t.integer :max_upload_size, limit: 8
      t.string :os
      t.text :comments
      t.boolean :needs_review, null: false
      t.datetime :completed_at

      t.timestamps null: false
    end
    add_index :orders, :drive_id
  end
end
