class Tiny::Products
  class << self
    def find_product(product_id, token)
      response = JSON.parse(HTTParty.get(ENV.fetch('OBTER_PRODUTO'),
                                         query: { token:,
                                                  formato: 'json',
                                                  id: product_id }))
      response.with_indifferent_access[:retorno]
    end

    def update_product(products, token)
      HTTParty.post(ENV.fetch('ALTERAR_PRODUTO'), body: {
                                token:,
                                formato: 'json',
                                produto: products.to_json
                              }, headers: {
                                'Cookie' => '__cf_bm=b7051RRfkZC9AV_x5yhIR1YwwFKbCBPhyfHyy6UkYiA-1714414033-1.0.1.1-yM8S6uVPTUHPbqgBucg.8Ar9U5shYRd5zAGggCvd88XerAZtCE9ti1Whloyh5bUX2DNyQQN92b7G1gORyv2Dmw',
                                'Content-Type' => 'application/x-www-form-urlencoded'
                              })
    end

    def search_products(situacao, token, pagina = nil)
      response = JSON.parse(HTTParty.get(ENV.fetch('PRODUTOS_PESQUISA'),
                                         query: {
                                          token:,
                                          formato: 'json',
                                          situacao:,
                                          pagina:
                                        }))
      response.with_indifferent_access[:retorno]
    end
  end
end
