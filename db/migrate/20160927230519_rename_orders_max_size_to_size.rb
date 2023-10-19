class RenameOrdersMaxSizeToSize < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :max_size, :size
  end
end
