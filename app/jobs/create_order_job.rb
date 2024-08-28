class CreateOrderJob < ActiveJob::Base
  def perform(origin)
    create_note(origin)
  end

  def create_order(kind)
    orders = Tiny::Orders.get_all_orders('faturado')
  end

  def mount_note(order)
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
        'marcadores' => [
          {
            'marcador' => {
              'descricao' => 'abcdef'
            }
          },
          {
            'marcador' => {
              'id' => '1234',
              'descricao' => ''
            }
          },
          {
            'marcador' => {
              'id' => '1234'
            }
          }
        ],
        'parcelas' => [
          {
            'parcela' => {
              'dias' => '30',
              'data' => '29/11/2014',
              'valor' => '53.84',
              'obs' => 'Obs Parcela 1',
              'forma_pagamento' => 'boleto',
              'meio_pagamento' => 'Bradesco X'
            }
          },
          {
            'parcela' => {
              'dias' => '60',
              'data' => '29/12/2014',
              'valor' => '53.83',
              'obs' => 'Obs Parcela 2',
              'forma_pagamento' => 'dinheiro'
            }
          },
          {
            'parcela' => {
              'dias' => '90',
              'data' => '27/01/2015',
              'valor' => '53.83',
              'obs' => 'Obs Parcela 3'
            }
          }
        ],
        'nome_transportador' => 'transportador teste',
        'forma_pagamento' => 'multiplas',
        'frete_por_conta' => 'E',
        'valor_frete' => '35.00',
        'valor_desconto' => '35.00',
        'numero_ordem_compra' => '',
        'numero_pedido_ecommerce' => '123',
        'situacao' => 'Aberto',
        'obs' => 'Observações do Pedido',
        'forma_envio' => 'c',
        'forma_frete' => 'PAC',
        'intermediador' => {
          'nome' => 'Intermediador Teste',
          'cnpj' => '00.000.000/0000-00',
          'cnpjPagamento' => '00.000.000/0000-00'
        }
      }
    }
  end
end
