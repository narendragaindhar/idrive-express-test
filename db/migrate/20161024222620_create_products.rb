class CreateProducts < ActiveRecord::Migration[5.2]
  def up
    say 'Creating table :products'
    create_table :products do |t|
      t.string :name, null: false
      t.timestamps null: false

      t.index :name, unique: true
    end

    say 'Creating the default records'
    Product.reset_column_information
    idrive = Product.create(name: 'IDrive')

    say 'Adding association to :customers'
    add_reference :customers, :product, index: true
    change_column_null :customers, :product_id, false, idrive.id
    change_column :customers, :product_id, :bigint, null: false, default: nil
    add_foreign_key :customers, :products

    say 'Fixing indexes in :customers'
    remove_index :customers, :username
    add_index :customers, %i[username product_id], unique: true

    say 'Adding association to :order_types'
    add_reference :order_types, :product, index: true
    change_column_null :order_types, :product_id, false, idrive.id
    change_column :order_types, :product_id, :bigint, null: false, default: nil
    add_foreign_key :order_types, :products
  end

  def down
    say 'Removing association in :order_types'
    remove_reference :order_types, :product, index: true, foreign_key: true

    say 'Fixing indexes in :customers'
    remove_index :customers, %i[username product_id]
    add_index :customers, :username, unique: true

    say 'Removing association in :customers'
    remove_reference :customers, :product, index: true, foreign_key: true

    say 'Dropping table :products'
    drop_table :products
  end
end
