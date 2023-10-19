class CreateOrderStates < ActiveRecord::Migration[5.2]
  def change
    create_table :order_states do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :order, index: true, foreign_key: true
      t.belongs_to :state, index: true, foreign_key: true
      t.text :comments
      t.boolean :did_notify, null: false
      t.boolean :is_public, null: false

      t.timestamps null: false
    end
  end
end
