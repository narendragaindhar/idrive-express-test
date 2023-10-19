class CreateDatacenters < ActiveRecord::Migration[5.2]
  def change
    create_table :datacenters do |t|
      t.belongs_to :address, index: true, foreign_key: true
      t.string :key
      t.string :name
      t.boolean :active, null: false

      t.timestamps null: false
    end
  end
end
