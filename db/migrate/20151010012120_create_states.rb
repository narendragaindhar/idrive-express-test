class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.belongs_to :express_kind, index: true, foreign_key: true
      t.string :key
      t.integer :percentage
      t.string :label
      t.text :description
      t.boolean :public_by_default, null: false
      t.boolean :notify_by_default, null: false

      t.timestamps null: false
    end
  end
end
