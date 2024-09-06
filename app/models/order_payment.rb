class OrderPayment < ApplicationRecord
  # Callbacks
  after_commit :calculate_days, on: [:create, :update]
  after_commit :calculate_amount, on: [:create, :update]

  # Associações
  belongs_to :order, optional: true
  belongs_to :order_payment_type

  # Métodos públicos

  def calculate_days
    return if date.nil?

    days_difference = (date - Date.today).to_i
    update_column(:days, days_difference)
  end

  def calculate_amount
    total_amount = order.order_products.joins(:product).sum('products.preco')
    update_column(:amount, total_amount)
  end
end
