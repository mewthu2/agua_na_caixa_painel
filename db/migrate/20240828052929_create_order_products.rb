class CreateOrderProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :order_products do |t|
      t.references :order, foreign_key: true, after: :id
      t.references :product, foreign_key: true, after: :id
      t.integer :quantidade
      t.timestamps
    end
  end
end
