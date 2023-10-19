class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.string :name, null: false
      t.text :description
      t.text :query, null: false
      t.string :frequency
      t.string :recipients

      t.timestamps
    end
  end
end
