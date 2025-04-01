class CreateOrderJob < ActiveJob::Base
  def perform(order)
    order.destiny == 'agua_na_caixa' ? token = ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA') : token = ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')

    attempt = Attempt.create(kinds: "create_order_#{order.destiny}")

    create_order(token, order, attempt)
  end

  def create_order(token, order, attempt)
    pedido = mount_order(order)

    attempt.update(requisition: pedido)
    begin
      tiny_order = Tiny::Orders.create_order(token, pedido)
    rescue StandardError => e
      attempt.update(error: e, status: :error)
    end

    match = tiny_order.match(/<status_processamento>(\d+)<\/status_processamento>/)
    tiny_order_id = tiny_order.match(/<id>(\d+)<\/id>/)[1].to_i

    status_processamento = match ? match[1].to_i : nil

    case status_processamento
    when 2
      message = 'Status de Processamento é 2. Executando ação específica para status 2.'
      puts message

      attempt.update(status_code: '403', message:)

      2
    when 3
      message = 'Status de Processamento é 3. Executando ação específica para status 3.'
      puts message

      attempt.update(status_code: '200', message:)
      order.update(tiny_order_id:)
      # TODO: adicionar o id do tiny tanto no attempt quanto na order
      3
    else
      message = 'Status de Processamento não reconhecido ou não encontrado.'
      puts message

      attempt.update(status_code: '500', message:)

      4
    end
  end

  def mount_order(order)
    {
      'pedido' => {
        'data_pedido' => order.created_at.strftime('%d/%m/%Y'),
        'data_prevista' => '',
        'cliente' => {
          'codigo' => order.contact.codigo,
          'nome' => order.contact.nome,
          'nome_fantasia' => order.contact.fantasia,
          'tipo_pessoa' => order.contact.tipo_pessoa,
          'cpf_cnpj' => order.contact.cpf_cnpj,
          'ie' => '',
          'rg' => '',
          'endereco' => order.use_contact_order ? order.contact.endereco : order.endereco,
          'numero' => order.use_contact_order ? order.contact.numero : order.numero,
          'complemento' => order.use_contact_order ? order.contact.complemento : order.complemento,
          'bairro' => order.use_contact_order ? order.contact.bairro : order.bairro,
          'cep' => order.use_contact_order ? order.contact.cep : order.cep,
          'cidade' => order.use_contact_order ? order.contact.cidade : '',
          'uf' => order.use_contact_order ? order.contact.uf : order.uf,
          'fone' => order.contact.fone
        },
        'itens' => order.order_products.map do |op|
          {
            'item' => {
              'codigo' => op.product.codigo,
              'descricao' => op.product.nome,
              'unidade' => op.product.unidade,
              'quantidade' => op.quantidade&.to_s,
              'valor_unitario' => op.price.present? ? op.price : op.product.preco
            }
          }
        end,
        'parcelas' => order.order_payments.map do |op|
          {
            'parcela' => {
              'dias' => op.days,
              'data' => op.date&.to_s,
              'valor' => op.amount,
              'obs' => op.note,
              'forma_pagamento' => op.order.preference_payment? ? op.order.contact.order_payment_type.payment_method : op.order_payment_type.payment_method,
              'meio_pagamento' => op.order.preference_payment? ? op.order.contact.order_payment_type.payment_channel : op.order_payment_type.payment_channel
            }
          }
        end,
        'obs' => order.observation
      }
    }
  end
end
