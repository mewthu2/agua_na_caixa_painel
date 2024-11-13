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

    def obtain_registration(token, id)
      response = JSON.parse(HTTParty.get(ENV.fetch('OBTER_CONTATO'),
                                         query: { token:,
                                                  formato: 'json',
                                                  id: }))
      response.with_indifferent_access[:retorno]
    end

    def update_registration(token, contact)
      HTTParty.post(ENV.fetch('ALTERAR_CONTATO'), body: {
                                                  token:,
                                                  formato: 'json',
                                                  contato: contact.to_json
                                                }, headers: {
                                                  'Cookie' => '__cf_bm=b7051RRfkZC9AV_x5yhIR1YwwFKbCBPhyfHyy6UkYiA-1714414033-1.0.1.1-yM8S6uVPTUHPbqgBucg.8Ar9U5shYRd5zAGggCvd88XerAZtCE9ti1Whloyh5bUX2DNyQQN92b7G1gORyv2Dmw',
                                                  'Content-Type' => 'application/x-www-form-urlencoded'
                                                })
    end

    def new_registration(token, contact)
      HTTParty.post(ENV.fetch('INCLUIR_CONTATO'), body: {
                                                  token:,
                                                  formato: 'json',
                                                  contato: contact.to_json
                                                }, headers: {
                                                  'Cookie' => '__cf_bm=b7051RRfkZC9AV_x5yhIR1YwwFKbCBPhyfHyy6UkYiA-1714414033-1.0.1.1-yM8S6uVPTUHPbqgBucg.8Ar9U5shYRd5zAGggCvd88XerAZtCE9ti1Whloyh5bUX2DNyQQN92b7G1gORyv2Dmw',
                                                  'Content-Type' => 'application/x-www-form-urlencoded'
                                                })
    end
  end
end
