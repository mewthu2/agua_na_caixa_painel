class Tiny::Sellers
  class << self
    def search_sellers(origin)
      response = JSON.parse(HTTParty.get(ENV.fetch('PESQUISA_FORNECEDOR'),
                                         query: { token: origin,
                                                  formato: 'json'
                                                }))
      response.with_indifferent_access[:retorno][:vendedores]
    end
  end
end
