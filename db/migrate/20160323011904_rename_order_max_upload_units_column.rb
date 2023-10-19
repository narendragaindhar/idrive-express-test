class RenameOrderMaxUploadUnitsColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :max_upload_size, :max_size
  end
end
