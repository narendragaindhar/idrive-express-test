class CustomerQuotaBigInt < ActiveRecord::Migration[5.2]
  def change
    change_column :customers, :quota, :integer, limit: 8
  end
end
