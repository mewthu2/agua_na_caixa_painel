class AddSellerFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :seller_id, :integer
    add_column :orders, :seller_name, :string
  end
end