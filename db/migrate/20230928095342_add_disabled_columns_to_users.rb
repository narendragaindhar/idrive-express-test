class AddDisabledColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :disabled_at, :datetime
    add_column :users, :disabled_reason, :string
  end
end
