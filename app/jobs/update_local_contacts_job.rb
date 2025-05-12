class UpdateLocalContactsJob < ActiveJob::Base
  def perform(origin)
    case origin
    when 'primeiros_passos'
      token = ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
    when 'agua_na_caixa'
      token = ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA')
    else
      raise ArgumentError, 'Origem inválida'
    end

    update_or_create_local_contacts(token, origin)
  end

  def update_or_create_local_contacts(token, origin)
    pagina = 1
    numero_paginas = 1

    while pagina <= numero_paginas
      tiny_contacts_response = Tiny::Registrations.search_registration(token, pagina)

      return unless tiny_contacts_response[:status] == 'OK'
      numero_paginas = tiny_contacts_response[:numero_paginas].to_i
      tiny_contacts = tiny_contacts_response[:contatos]

      tiny_contacts.each do |tc|
        sleep(0.5)
        contact_data = tc[:contato]
        contact = Contact.find_or_initialize_by(id: contact_data[:id])

        contact_data[:origin] = origin

        contact.assign_attributes(contact_data.reject { |_, v| v.nil? || v == '' })
        contact.save
      end

      pagina += 1
    end
  end
end
