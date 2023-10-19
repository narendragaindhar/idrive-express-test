class AddLocationAwarenessToState < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :is_out_of_our_hands, :boolean, default: false, null: false, after: :notify_by_default
    add_column :states, :leaves_us, :boolean, default: false, null: false, after: :is_out_of_our_hands
  end
end
