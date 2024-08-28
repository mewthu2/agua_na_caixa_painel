class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order

  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos
  add_scope :search do |value|
    joins(:product)
      .where('products.origin LIKE :valor OR
             products.data_criacao LIKE :valor OR
             products.nome LIKE :valor OR
             products.codigo LIKE :valor OR
             products.preco LIKE :valor OR
             products.preco_promocional LIKE :valor OR
             products.unidade LIKE :valor OR
             products.gtin LIKE :valor OR
             products.tipoVariacao LIKE :valor OR
             products.localizacao LIKE :valor OR
             products.preco_custo LIKE :valor OR
             products.preco_custo_medio LIKE :valor OR
             products.situacao LIKE :valor OR
             products.id LIKE :valor', valor: "%#{value}%")
  end

  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
