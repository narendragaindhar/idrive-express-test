class RenameExpressKindToOrderType < ActiveRecord::Migration[5.2]
  def up
    say_with_time 'Removing foreign keys' do
      remove_foreign_key :orders, :express_kinds
      remove_foreign_key :states, :express_kinds
    end

    say 'Renaming table'
    rename_table :express_kinds, :order_types

    say 'Renaming columns'
    rename_column :orders, :express_kind_id, :order_type_id
    rename_column :states, :express_kind_id, :order_type_id

    say_with_time 'Adding foreign keys' do
      add_foreign_key :orders, :order_types
      add_foreign_key :states, :order_types
    end
  end

  def down
    say_with_time 'Removing foreign keys' do
      remove_foreign_key :orders, :order_types
      remove_foreign_key :states, :order_types
    end

    say 'Renaming table'
    rename_table :order_types, :express_kinds

    say 'Renaming columns'
    rename_column :orders, :order_type_id, :express_kind_id
    rename_column :states, :order_type_id, :express_kind_id

    say_with_time 'Adding foreign keys' do
      add_foreign_key :orders, :express_kinds
      add_foreign_key :states, :express_kinds
    end
  end
end
