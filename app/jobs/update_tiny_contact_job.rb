class UpdateTinyContactJob < ActiveJob::Base
  def perform(contact)
    token = contact.origin == 'agua_na_caixa' ? ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA') : ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
    attempt = Attempt.create(kinds: "update_contact_#{contact.origin}")
    update_tiny_contact(token, contact, attempt)
  end

  def update_tiny_contact(token, contact, attempt)
    contact_to_be_updated = mount_contact(contact)
    response = Tiny::Registrations.update_registration(token, contact_to_be_updated)
    process_response(response, attempt)
  end

  def process_response(response_json, attempt)
    response = JSON.parse(response_json)
    status = response.dig('retorno', 'status')
    registro = response.dig('retorno', 'registros', 0, 'registro') || {}
    sequencia = registro['sequencia']
    registro_id = registro['id']

    attempt.update(
      status_code: status,
      message: "Sequência: #{sequencia}",
      tiny_order_id: registro_id,
      requisition: response_json
    )
  end

  def mount_contact(contact)
    {
      'contatos' => [
        {
          'contato' => {
            'sequencia' => '1',
            'codigo' => contact.codigo,
            'nome' => contact.nome,
            'tipo_pessoa' => contact.tipo_pessoa,
            'cpf_cnpj' => contact.cpf_cnpj,
            'ie' => '',
            'rg' => '',
            'im' => '',
            'endereco' => contact.endereco,
            'numero' => contact.numero,
            'complemento' => contact.complemento || '',
            'bairro' => contact.bairro,
            'cep' => contact.cep,
            'cidade' => contact.cidade,
            'uf' => contact.uf,
            'pais' => '',
            'contatos' => '',
            'fone' => contact.fone,
            'fax' => '',
            'celular' => '',
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
