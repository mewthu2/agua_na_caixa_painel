class AddTinyOrderIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :tiny_order_id, :integer, after: :contact_id
  end
end
