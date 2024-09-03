class Order < ApplicationRecord
  enum destiny: [:primeiros_passos, :agua_na_caixa]
  # Callbacks
  # Associacoes
  has_many :order_products, dependent: :destroy
  has_many :order_payments
  # Validacoes
  accepts_nested_attributes_for :order_products, allow_destroy: true
  # Escopos
  add_scope :search do |value|
    where('
      orders.destiny LIKE :value
    ', value: "%#{value}%")
  end
  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
