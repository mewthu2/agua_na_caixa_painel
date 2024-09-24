class AddPriceToOrderProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :order_products, :price, :string, after: :quantidade
  end
end
