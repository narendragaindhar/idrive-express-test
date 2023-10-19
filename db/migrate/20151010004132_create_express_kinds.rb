class CreateExpressKinds < ActiveRecord::Migration[5.2]
  def change
    create_table :express_kinds do |t|
      t.string :key
      t.string :name

      t.timestamps null: false
    end
  end
end
