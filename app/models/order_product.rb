class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order

  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos

  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
