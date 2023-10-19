class AddIndexesForSearch < ActiveRecord::Migration[5.0]
  def change
    add_index :customers, :email
    add_index :customers, :server
    add_index :customers, :name
    add_index :order_types, :key
    add_index :orders, :size
    add_index :states, :label
    add_index :users, :name
  end
end
