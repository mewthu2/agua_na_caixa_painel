class AddContactsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :contact, foreign_key: true, after: :id
  end
end
