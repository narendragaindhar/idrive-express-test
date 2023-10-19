class CreateUserRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_roles do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :role, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :user_roles, %i[user_id role_id], unique: true
  end
end
