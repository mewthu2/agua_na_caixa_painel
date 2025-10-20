class HomeController < ApplicationController
  def index
    redirect_to new_user_session_path unless current_user

    @current_user_profile = current_user.profile_id

    @sellers = User.where(profile_id: [2, 3]).order(:name)

    base_orders = Order.all

    if params[:seller_id].present? && current_user.profile_id == 1
      seller = User.find(params[:seller_id])
      seller_ids = [seller.seller_id_primeiros_passos, seller.seller_id_agua_na_caixa].compact
      base_orders = base_orders.where(seller_id: seller_ids) if seller_ids.any?
    elsif current_user.profile_id == 3
      seller_ids = [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa].compact
      base_orders = base_orders.where(seller_id: seller_ids) if seller_ids.any?
    end

    @recent_orders = base_orders.includes(:contact).order(created_at: :desc).limit(5)

    @orders_today = base_orders.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
    @orders_this_week = base_orders.where(created_at: 1.week.ago..Time.current)
    @orders_this_month = base_orders.where(created_at: 1.month.ago..Time.current)

    @total_orders = base_orders.count
    @orders_integrated = base_orders.where.not(tiny_order_id: nil).count
    @orders_pending = base_orders.where(tiny_order_id: nil).count

    @orders_by_day = orders_by_day_data(base_orders)
    @orders_by_seller = orders_by_seller_data(base_orders)
    @orders_by_destiny = orders_by_destiny_data(base_orders)
    @payment_methods = payment_methods_data(base_orders)
  end

  private

  def orders_by_day_data(base_orders)
    (6.days.ago.to_date..Date.current).map do |date|
      orders = base_orders.where(created_at: date.beginning_of_day..date.end_of_day)
      [date.strftime('%d/%m'), orders.count]
    end
  end

  def orders_by_seller_data(base_orders)
    base_orders.where.not(seller_name: [nil, ''])
               .group(:seller_name)
               .count
               .map { |seller, count| [seller.truncate(15), count] }
               .sort_by { |_, count| -count }
               .first(10)
  end

  def orders_by_destiny_data(base_orders)
    destiny_counts = base_orders.group(:destiny).count

    result = {}
    destiny_counts.each do |destiny, count|
      next if destiny.nil?

      label = case destiny.to_s
              when 'primeiros_passos'
                'Primeiros Passos'
              when 'agua_na_caixa'
                'Água na Caixa'
              else
                destiny.to_s.humanize
              end

      result[label] = count
    end

    result.presence || { 'Sem dados' => 0 }
  end

  def payment_methods_data(base_orders)
    OrderPayment.joins(:order, :order_payment_type)
                .where(orders: { id: base_orders.ids })
                .group('order_payment_types.payment_method')
                .count
                .map { |method, count| [method || 'Não definido', count] }
  end
end
