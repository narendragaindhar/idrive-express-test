class RenameDatacenterToDestination < ActiveRecord::Migration[5.2]
  #
  # heads up! keep the migration methods up() and down() separate instead of
  # using the newer change() method. rails is not smart enough to do this
  # migration properly unless you manually specify in what order things need to
  # happen. many tears were shed here trying to get this right so please do
  # yourself a favor and keep them apart.
  #

  def up
    remove_foreign_key :orders, :datacenters
    rename_table :datacenters, :destinations
    rename_column :orders, :datacenter_id, :destination_id
    add_foreign_key :orders, :destinations

    say 'Fix Address polymorphic data'
    execute <<-SQL
      UPDATE addresses
      SET
        addressable_type = 'Destination'
      WHERE
        addressable_type = 'Datacenter'
      ;
    SQL
  end

  def down
    remove_foreign_key :orders, :destinations
    rename_table :destinations, :datacenters
    rename_column :orders, :destination_id, :datacenter_id
    add_foreign_key :orders, :datacenters

    say 'Fix Address polymorphic data'
    execute <<-SQL
      UPDATE addresses
      SET
        addressable_type = 'Datacenter'
      WHERE
        addressable_type = 'Destination'
      ;
    SQL
  end
end
