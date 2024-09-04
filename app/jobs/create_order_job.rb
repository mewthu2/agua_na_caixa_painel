class CreateOrderJob < ActiveJob::Base
  def perform(origin)
    origin == 'agua_na_caixa' ? ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA') : ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')

    create_order(origin, token)
  end

  def create_order(_origin, token)
    order = Tiny::Orders.create_order(token, pedido)
  end

  def mount_order(order)
    {
      'pedido' => {
        'data_pedido' => order.created_at.strftime('%d/%m/%Y'),
        'data_prevista' => order.preview_date.strftime('%d/%m/%Y'),
        'cliente' => {
          'codigo' => order.contact.codigo,
          'nome' => order.contact.nome,
          'nome_fantasia' => order.contact.fantasia,
          'tipo_pessoa' => order.contact.tipo_pessoa,
          'cpf_cnpj' => order.contact.cpf_cnpj,
          'ie' => order.contact.ie,
          'rg' => '',
          'endereco' => order.contact.endereco,
          'numero' => order.contact.numero,
          'complemento' => order.contact.complemento,
          'bairro' => order.contact.bairro,
          'cep' => order.contact.cep,
          'cidade' => order.contact.cidade,
          'uf' => order.contact.uf,
          'fone' => order.contact.fone
        },
        'itens' => order.order_products.map do |op|
          {
            'item' => {
              'codigo' => op.codigo,
              'descricao' => op.descricao,
              'unidade' => op.unidade,
              'quantidade' => op.quantidade,
              'valor_unitario' => op.valor_unitario
            }
          }
        end,
        'parcelas' => [
          {
            'parcela' => {
              'dias' => op.order_payment.days,
              'data' => op.order_payment.date,
              'valor' => op.order_payment.amount,
              'obs' => op.order_payment.note,
              'forma_pagamento' => op.order_payment.order_payment_type.payment_method,
              'meio_pagamento' => op.order_payment.order_payment_type.payment_channel
            }
          }
        ]
      }
    }
  end
end
