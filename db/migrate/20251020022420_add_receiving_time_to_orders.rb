class AddReceivingTimeToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :receiving_time, :time
  end
end
