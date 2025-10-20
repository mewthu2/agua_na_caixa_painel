class Tiny::Invoices
  class << self
    def get_invoices(tiny_order_id)
      get_invoices_with_token(tiny_order_id, ENV.fetch('TOKEN_TINY_PRODUCTION'))
    end

    def get_invoices_with_token(tiny_order_id, token)
      pedido = obtain_order_by_id(tiny_order_id, token)
      id_nf  = pedido&.dig(:id_nota_fiscal).presence
      return [] unless id_nf

      nf = obtain_invoice_with_token(id_nf, token)
      nf.present? ? [{ nota_fiscal: nf }] : []
    end

    def get_invoice_xml(token, invoice_id)
      response = HTTParty.post(
        ENV.fetch('OBTER_XML_NOTA_FISCAL'),
        body: {
          token:,
          id: invoice_id,
          formato: 'XML'
        }
      )

      if response.success?
        parsed = response.parsed_response

        if parsed['retorno'] && parsed['retorno']['status'] == 'OK'
          parsed['retorno']['xml_nfe']
        else
          error_message = parsed['retorno']['erros'] rescue 'Erro desconhecido'
          Rails.logger.error "[Tiny::Invoices] Erro na API: #{error_message}"
          nil
        end
      else
        Rails.logger.error "[Tiny::Invoices] Erro HTTP: #{response.code}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "[Tiny::Invoices] Exceção: #{e.message}"
      nil
    end

    def obtain_order_by_id(order_id, token)
      resp = HTTParty.get(
        ENV.fetch('PEDIDO_OBTER'),
        query: {
          token: token,
          formato: 'json',
          id: order_id
        }
      )
      json = JSON.parse(resp.body) rescue {}
      json = json.with_indifferent_access
      json.dig(:retorno, :pedido)
    end

    def obtain_invoice_with_token(invoice_id, token)
      resp = HTTParty.get(
        ENV.fetch('OBTER_NOTA_FISCAL'),
        query: {
          token: token,
          formato: 'json',
          id: invoice_id
        }
      )
      json = JSON.parse(resp.body) rescue {}
      json.with_indifferent_access.dig(:retorno, :nota_fiscal)
    end

    def obtain_invoice(invoice_id)
      obtain_invoice_with_token(invoice_id, ENV.fetch('TOKEN_TINY_PRODUCTION'))
    end

    def obtain_xml(invoice_id)
      HTTParty.get(
        ENV.fetch('OBTER_XML_NOTA_FISCAL'),
        query: { token: ENV.fetch('TOKEN_TINY_PRODUCTION'), formato: 'string', id: invoice_id }
      )
    end

    def invoice_emition(invoice_id)
      HTTParty.get(
        ENV.fetch('EMITIR_NOTA_FISCAL'),
        query: { token: ENV.fetch('TOKEN_TINY_PRODUCTION'), formato: 'string', id: invoice_id }
      )
    end
  end
end
