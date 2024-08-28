class Order < ApplicationRecord
  # Callbacks
  # Associacoes
  has_many :order_products, dependent: :destroy
  # Validacoes
  accepts_nested_attributes_for :order_products, allow_destroy: true
  # Escopos

  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
