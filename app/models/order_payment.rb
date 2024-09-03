class OrderPayment < ApplicationRecord
  # Callbacks
  # Associacoes
  belongs :order
  belongs :order_payment_type
  # Validacoes

  # Escopos

  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
