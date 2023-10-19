class FixHabtmUserRoles < ActiveRecord::Migration[5.2]
  def up
    say 'Renaming table'
    rename_table :user_roles, :roles_users

    say 'Removing columns'
    remove_column :roles_users, :created_at
    remove_column :roles_users, :updated_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Can\'t recover missing column data'
  end
end
