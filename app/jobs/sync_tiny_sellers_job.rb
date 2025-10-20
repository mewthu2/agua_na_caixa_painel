# frozen_string_literal: true

class SyncTinySellersJob < ApplicationJob
  queue_as :default

  def perform
    users = User.all
    Rails.logger.info("[SyncTinySellersJob] Iniciando sincronização de #{users.count} usuários...")

    sync_all(users, 'agua_na_caixa', ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA'))

    sync_all(users, 'primeiros_passos', ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS'))

    Rails.logger.info('[SyncTinySellersJob] ✅ Sincronização concluída!')
  end

  private

  def sync_all(users, origin, token)
    return if token.blank?

    Rails.logger.info("[SyncTinySellersJob] 🔄 Consultando vendedores para #{origin}...")

    users.find_each do |user|
      case origin
      when 'agua_na_caixa'
        next if user.seller_id_agua_na_caixa.present?
      when 'primeiros_passos'
        next if user.seller_id_primeiros_passos.present?
      end

      seller_id = Tiny::Sellers.sync_seller_for_user(user, token, origin)

      if seller_id.present?
        Rails.logger.info("[SyncTinySellersJob] ✅ Atualizado User ##{user.id} (#{origin}) com seller_id #{seller_id}")
      else
        Rails.logger.warn("[SyncTinySellersJob] ⚠️ Nenhum vendedor encontrado para '#{user.name}' (#{origin})")
      end

      sleep 0.3
    rescue StandardError => e
      Rails.logger.error("[SyncTinySellersJob] ❌ Erro ao sincronizar User ##{user.id} (#{origin}): #{e.message}")
    end
  end
end
