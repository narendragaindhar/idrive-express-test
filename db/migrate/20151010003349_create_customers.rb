class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :username
      t.string :email
      t.string :name
      t.string :phone
      t.string :server
      t.integer :priority
      t.integer :quota

      t.timestamps null: false
    end
  end
end
