class CreateOrderPaymentTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :order_payment_types do |t|
      t.string :payment_method, null: false
      t.string :payment_channel, null: false

      t.timestamps
    end
  end
end
