class AddUniqueIndexToDriveIdentificationNumberSerial < ActiveRecord::Migration[5.2]
  def change
    add_index :drives, %i[identification_number serial], unique: true
  end
end
