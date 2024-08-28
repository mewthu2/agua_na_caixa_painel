class Product < ApplicationRecord
  enum origin: [:primeiros_passos, :agua_na_caixa]
  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos
  add_scope :search do |value|
    where('products.origin LIKE :valor OR
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
  def self.update_local_products(origin)
    case origin
    when 'primeiros_passos'
      token = ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
    when 'agua_na_caixa'
      token = ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA')
    else
      raise ArgumentError, 'Origem inválida'
    end

    pagina = 1
    numero_paginas = 1

    while pagina <= numero_paginas
      tiny_products_response = Tiny::Products.search_products('', token, pagina)

      return unless tiny_products_response[:status] == 'OK'
      numero_paginas = tiny_products_response[:numero_paginas].to_i
      tiny_products = tiny_products_response[:produtos]

      tiny_products.each do |tp|
        product_data = tp[:produto]
        product = Product.find_or_initialize_by(id: product_data[:id])

        product_data[:origin] = origin

        product.assign_attributes(product_data.reject { |_, v| v.nil? || v == '' })
        product.save
      end

      pagina += 1
    end
  end
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
