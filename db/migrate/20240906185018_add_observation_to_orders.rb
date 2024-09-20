class AddObservationToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :observation, :integer, after: :tiny_order_id
  end
end
