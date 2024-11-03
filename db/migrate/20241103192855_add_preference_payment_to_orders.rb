class AddPreferencePaymentToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :preference_payment, :boolean, after: :use_contact_order, default: false
  end
end
