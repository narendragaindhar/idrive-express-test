class AddUniqueIndexToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_index :customers, :username, unique: true
  end
end
