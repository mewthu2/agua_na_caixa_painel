# frozen_string_literal: true

class Tiny::Sellers
  class << self
    def find_seller_id(token, name)
      return if name.blank?

      url = ENV.fetch('PESQUISA_FORNECEDOR')

      response = HTTParty.get(url, query: {
        token:,
        formato: 'json',
        pesquisa: name
      })

      body = response.body.to_s.strip
      if body.match?(/File not found/i) || body.blank?
        Rails.logger.warn("[Tiny::Sellers] ⚠️ Endpoint inválido ou resposta vazia em #{url}")
        return nil
      end

      parsed = JSON.parse(body).with_indifferent_access

      if parsed.dig(:retorno, :status) == 'OK'
        vendedores = parsed.dig(:retorno, :vendedores)
        vendedor = vendedores&.first&.dig(:vendedor)
        vendedor&.dig(:id)
      else
        Rails.logger.warn("[Tiny::Sellers] ⚠️ Nenhum vendedor encontrado para '#{name}'")
        nil
      end
    rescue JSON::ParserError
      Rails.logger.error("[Tiny::Sellers] ❌ Erro ao interpretar resposta da API Tiny: #{response&.body}")
      nil
    rescue StandardError => e
      Rails.logger.error("[Tiny::Sellers] ❌ Erro ao consultar vendedor '#{name}': #{e.message}")
      nil
    end

    def sync_seller_for_user(user, token, origin)
      seller_name = user.name.to_s.strip
      return if seller_name.blank?

      seller_id = find_seller_id(token, seller_name)
      return unless seller_id

      field =
        case origin
        when 'primeiros_passos' then :seller_id_primeiros_passos
        when 'agua_na_caixa' then :seller_id_agua_na_caixa
        end

      return unless field

      user.update!(field => seller_id)
      Rails.logger.info("[Tiny::Sellers] ✅ Vendedor encontrado no Tiny para #{user.name} (#{origin}) → ID #{seller_id}")
      seller_id
    rescue StandardError => e
      Rails.logger.error("[Tiny::Sellers] ❌ Erro ao atualizar vendedor para #{user.name}: #{e.message}")
      nil
    end
  end
end
