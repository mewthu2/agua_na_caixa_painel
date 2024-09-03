class OrderPaymentType < ApplicationRecord
  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos
  add_scope :search do |value|
    where('
      order_payment_types.payment_method LIKE :value OR
      order_payment_types.payment_channel LIKE :value
    ', value: "%#{value}%")
  end
  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
