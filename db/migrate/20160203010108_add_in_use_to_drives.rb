class AddInUseToDrives < ActiveRecord::Migration[5.2]
  def change
    add_column :drives, :in_use, :boolean, default: false, after: :active
  end
end
