class CreateOrderJob < ActiveJob::Base
  def perform(order)
    order.destiny == 'agua_na_caixa' ? token = ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA') : token = ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')

    attempt = Attempt.create(kinds: :create_order)

    create_order(token, order)
  end

  def create_order(token, order)
    pedido = mount_order(order)

    begin
      order = Tiny::Orders.create_order(token, pedido)
    rescue StandardError => e
      attempt.update(error: e, status: :error)
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
          'cidade' => order.use_contact_order ? order.contact.cidade : order.cidade,
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
              'valor_unitario' => op.product.preco
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
              'forma_pagamento' => op.order_payment_type.payment_method,
              'meio_pagamento' => op.order_payment_type.payment_channel
            }
          }
        end
      }
    }
  end
end
