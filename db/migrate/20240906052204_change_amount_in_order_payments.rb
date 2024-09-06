class ChangeAmountInOrderPayments < ActiveRecord::Migration[6.1]
  def change
    change_column :order_payments, :amount, :decimal, null: true
  end
end
