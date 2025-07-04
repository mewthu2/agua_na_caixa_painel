class ChangeAmountPrecisionInOrderPayments < ActiveRecord::Migration[7.1]
  def change
    change_column :order_payments, :amount, :decimal, precision: 10, scale: 2
  end
end
