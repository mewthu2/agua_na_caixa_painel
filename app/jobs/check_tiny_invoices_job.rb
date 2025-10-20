class CheckTinyInvoicesJob < ApplicationJob
  queue_as :default

  def perform
    orders = Order.where(id_nota_fiscal: nil).where.not(tiny_order_id: nil)
    Rails.logger.info("[CheckTinyInvoicesJob] Verificando #{orders.count} pedidos sem nota fiscal...")

    orders.find_each do |order|
      token = select_token(order)
      next unless token

      invoice_id = fetch_invoice_id(order.tiny_order_id, token)

      if invoice_id
        xml_content = Tiny::Invoices.get_invoice_xml(token, invoice_id)

        if xml_content && order.xml_nota_fiscal.blank?
          order.update!(
            id_nota_fiscal: invoice_id,
            xml_nota_fiscal: xml_content
          )
          Rails.logger.info("[CheckTinyInvoicesJob] ✅ Pedido #{order.id} atualizado com nota fiscal #{invoice_id} e XML")
        elsif xml_content.blank?
          order.update!(id_nota_fiscal: invoice_id)
          Rails.logger.warn("[CheckTinyInvoicesJob] ⚠️ Pedido #{order.id} atualizado com nota fiscal #{invoice_id}, mas XML não encontrado")
        else
          order.update!(id_nota_fiscal: invoice_id) if order.id_nota_fiscal.blank?
          Rails.logger.info("[CheckTinyInvoicesJob] 🔄 Pedido #{order.id} já possuía XML, apenas ID atualizado")
        end
      else
        Rails.logger.info("[CheckTinyInvoicesJob] ❌ Nenhuma nota encontrada para pedido #{order.id}")
      end
    rescue StandardError => e
      Rails.logger.error("[CheckTinyInvoicesJob] Erro ao verificar pedido #{order.id}: #{e.message}")
    end
  end

  private

  def select_token(order)
    case order.destiny
    when 'agua_na_caixa'
      ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA')
    when 'primeiros_passos'
      ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
    else
      Rails.logger.warn("[CheckTinyInvoicesJob] ⚠️ Destiny desconhecido '#{order.destiny}' no pedido #{order.id}")
      nil
    end
  end

  def fetch_invoice_id(tiny_order_id, token)
    notas = Tiny::Invoices.get_invoices_with_token(tiny_order_id, token)
    return nil unless notas.present?

    nota = notas.find { |n| n.dig(:nota_fiscal, :id_venda).to_i == tiny_order_id.to_i }
    nota&.dig(:nota_fiscal, :id)
  end
end
