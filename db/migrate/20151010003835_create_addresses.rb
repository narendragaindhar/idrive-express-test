class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :recipient
      t.string :organization
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps null: false
    end
  end
end
