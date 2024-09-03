class CreateOrderPayments < ActiveRecord::Migration[7.1]
  def change
    create_table :order_payments do |t|
      t.references :order_payment_types, foreign_key: true, after: :id
      t.references :order, foreign_key: true, after: :id
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :days, null: false
      t.date :date, null: false
      t.string :note

      t.timestamps
    end
  end
end
