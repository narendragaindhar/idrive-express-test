class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.string :description, null: false

      t.timestamps null: false
    end
    add_index :roles, :key, unique: true
  end
end
