class CreateDriveEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :drive_events do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :drive_id
      t.text :event

      t.timestamps null: false
    end
    add_index :drive_events, :drive_id
  end
end
