class AddKindsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :destiny, :bigint, null: false, default: 0
  end
end
