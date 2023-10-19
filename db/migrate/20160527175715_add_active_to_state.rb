class AddActiveToState < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :active, :boolean, default: true, null: false, after: :description
  end
end
