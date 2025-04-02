class ChangeObservationTypeInOrders < ActiveRecord::Migration[7.1]
  def up
    change_column :orders, :observation, :text
  end

  def down
    change_column :orders, :observation, :integer
  end
end
