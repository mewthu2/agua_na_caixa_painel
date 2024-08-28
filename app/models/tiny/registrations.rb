class Tiny::Registrations
  class << self
    def search_registration(token, pagina)
      response = JSON.parse(HTTParty.get(ENV.fetch('PESQUISA_CONTATOS'),
                                         query: { token:,
                                                  formato: 'json',
                                                  pagina:,
                                                  pesquisa: '' }))
      response.with_indifferent_access[:retorno]
    end
  end
end
