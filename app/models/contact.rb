class Contact < ApplicationRecord
  enum origin: [:primeiros_passos, :agua_na_caixa]
  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos
  add_scope :search do |value|
    where('contacts.origin LIKE :valor OR
         contacts.codigo LIKE :valor OR
         contacts.nome LIKE :valor OR
         contacts.fantasia LIKE :valor OR
         contacts.tipo_pessoa LIKE :valor OR
         contacts.cpf_cnpj LIKE :valor OR
         contacts.endereco LIKE :valor OR
         contacts.numero LIKE :valor OR
         contacts.complemento LIKE :valor OR
         contacts.bairro LIKE :valor OR
         contacts.cep LIKE :valor OR
         contacts.cidade LIKE :valor OR
         contacts.uf LIKE :valor OR
         contacts.email LIKE :valor OR
         contacts.fone LIKE :valor OR
         contacts.id_lista_preco LIKE :valor OR
         contacts.id_vendedor LIKE :valor OR
         contacts.nome_vendedor LIKE :valor OR
         contacts.situacao LIKE :valor OR
         contacts.data_criacao LIKE :valor OR
         contacts.id LIKE :valor', valor: "%#{value}%")
  end

  # Metodos estaticos
  def self.update_local_contacts(origin)
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
      tiny_contacts_response = Tiny::Registrations.search_registration(token, pagina)

      return unless tiny_contacts_response[:status] == 'OK'
      numero_paginas = tiny_contacts_response[:numero_paginas].to_i
      tiny_contacts = tiny_contacts_response[:contatos]

      tiny_contacts.each do |tc|
        contact_data = tc[:contato]
        contact = Contact.find_or_initialize_by(id: contact_data[:id])

        contact_data[:origin] = origin

        contact.assign_attributes(contact_data.reject { |_, v| v.nil? || v == '' })
        contact.save
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
