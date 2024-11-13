class TinyContactJob < ActiveJob::Base
  attr_reader :contact, :function, :token, :attempt

  def perform(contact, function)
    @contact = contact
    @function = function
    @token = fetch_token
    @attempt = create_attempt

    case function
    when 'create'
      create_tiny_contact
    when 'update'
      update_tiny_contact
    end
  end

  private

  def fetch_token
    ENV.fetch(contact.origin == 'agua_na_caixa' ? 'TOKEN_TINY_AGUA_NA_CAIXA' : 'TOKEN_TINY_PRIMEIROS_PASSOS')
  end

  def create_attempt
    Attempt.create(kinds: "#{function}_contact_#{contact.origin}")
  end

  def create_tiny_contact
    contact_data = build_contact_data
    response = Tiny::Registrations.new_registration(token, contact_data)
    handle_response(response)
  end

  def update_tiny_contact
    contact_data = build_contact_data
    response = Tiny::Registrations.update_registration(token, contact_data)
    handle_response(response)
  end

  def handle_response(response_json)
    response = JSON.parse(response_json)
    status = response.dig('retorno', 'status')
    registration = response.dig('retorno', 'registros', 0, 'registro') || {}

    contact.update(id: registration['id'])

    attempt.update(
      status_code: status,
      message: "Sequência: #{registration['sequencia']}",
      tiny_order_id: registration['id'],
      requisition: response_json
    )
  end

  def build_contact_data
    {
      'contatos' => [
        {
          'contato' => {
            'sequencia' => '1',
            'codigo' => contact.codigo,
            'nome' => contact.nome,
            'tipo_pessoa' => contact.tipo_pessoa,
            'cpf_cnpj' => contact.cpf_cnpj,
            'endereco' => contact.endereco,
            'numero' => contact.numero,
            'complemento' => contact.complemento || '',
            'bairro' => contact.bairro,
            'cep' => contact.cep,
            'cidade' => contact.cidade,
            'uf' => contact.uf,
            'fone' => contact.fone,
            'email' => contact.email,
            'id_vendedor' => contact.id_vendedor || '',
            'situacao' => 'A',
            'obs' => ''
          }
        }
      ]
    }
  end
end
