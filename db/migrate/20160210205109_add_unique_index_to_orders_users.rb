class AddUniqueIndexToOrdersUsers < ActiveRecord::Migration[5.2]
  def up
    remove_index :orders_users, %i[order_id user_id]
    add_index :orders_users, %i[order_id user_id], unique: true
  end

  def down
    remove_index :orders_users, %i[order_id user_id]
    add_index :orders_users, %i[order_id user_id]
  end
end
