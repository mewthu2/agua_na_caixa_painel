class AddOrderPaymentTypeToContacts < ActiveRecord::Migration[7.1]
  def change
    add_reference :contacts, :order_payment_type, foreign_key: true, after: :id
  end
end
