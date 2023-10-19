class AddressesPolymorphic < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :addressable_id,   :integer
    add_column :addresses, :addressable_type, :string
    add_index  :addresses, %i[addressable_id addressable_type]

    remove_foreign_key :datacenters, :addresses
    remove_column :datacenters, :address_id, :integer

    remove_foreign_key :orders, :addresses
    remove_column :orders, :address_id, :integer
  end
end
