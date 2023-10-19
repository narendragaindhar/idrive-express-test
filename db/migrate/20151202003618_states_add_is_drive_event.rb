class StatesAddIsDriveEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :is_drive_event, :boolean, default: true, null: false
  end
end
