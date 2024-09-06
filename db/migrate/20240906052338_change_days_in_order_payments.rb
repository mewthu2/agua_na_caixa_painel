class ChangeDaysInOrderPayments < ActiveRecord::Migration[7.1]
  def change
    change_column :order_payments, :days, :decimal, null: true
  end
end
