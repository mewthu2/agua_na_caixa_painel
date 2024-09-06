class RenameOrderPaymentTypesIdToOrderPaymentTypeIdInOrderPayments < ActiveRecord::Migration[6.1]
  def change
    rename_column :order_payments, :order_payment_types_id, :order_payment_type_id
  end
end
