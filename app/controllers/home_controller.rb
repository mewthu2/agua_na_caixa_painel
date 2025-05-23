class HomeController < ApplicationController
  def index
    redirect_to new_user_session_path unless current_user
    
    # Dados para os gráficos
    @orders_today = Order.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
    @orders_this_week = Order.where(created_at: 1.week.ago..Time.current)
    @orders_this_month = Order.where(created_at: 1.month.ago..Time.current)
    
    # Filtrar por perfil se necessário
    if current_user.profile_id == 3
      seller_ids = [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]
      @orders_today = @orders_today.where(seller_id: seller_ids)
      @orders_this_week = @orders_this_week.where(seller_id: seller_ids)
      @orders_this_month = @orders_this_month.where(seller_id: seller_ids)
    end
    
    # Estatísticas gerais
    @total_orders = Order.count
    @orders_integrated = Order.where.not(tiny_order_id: nil).count
    @orders_pending = Order.where(tiny_order_id: nil).count
    @total_revenue = calculate_total_revenue
    
    # Dados para gráficos
    @orders_by_day = orders_by_day_data
    @orders_by_seller = orders_by_seller_data
    @orders_by_destiny = orders_by_destiny_data
    @revenue_by_month = revenue_by_month_data
    @payment_methods = payment_methods_data
    @orders_status = orders_status_data
  end
  
  private
  
  def calculate_total_revenue
    OrderPayment.joins(:order).sum(:amount)
  end
  
  def orders_by_day_data
    (6.days.ago.to_date..Date.current).map do |date|
      orders = Order.where(created_at: date.beginning_of_day..date.end_of_day)
      orders = orders.where(seller_id: [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]) if current_user.profile_id == 3
      [date.strftime('%d/%m'), orders.count]
    end
  end
  
  def orders_by_seller_data
    orders = Order.where.not(seller_name: [nil, ''])
    orders = orders.where(seller_id: [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]) if current_user.profile_id == 3
    
    orders.group(:seller_name)
          .count
          .map { |seller, count| [seller.truncate(15), count] }
          .sort_by { |_, count| -count }
          .first(10)
  end
  
  def orders_by_destiny_data
    orders = Order.all
    orders = orders.where(seller_id: [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]) if current_user.profile_id == 3
    
    orders.group(:destiny)
          .count
          .map { |destiny, count| [destiny&.humanize || 'Não definido', count] }
  end
  
  def revenue_by_month_data
    # Gerar array de meses dos últimos 6 meses
    months = []
    6.times do |i|
      month_date = i.months.ago.beginning_of_month
      months << month_date
    end
    
    months.reverse.map do |month_start|
      month_end = month_start.end_of_month
      
      orders = Order.where(created_at: month_start..month_end)
      orders = orders.where(seller_id: [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]) if current_user.profile_id == 3
      
      revenue = OrderPayment.joins(:order).where(orders: { id: orders.ids }).sum(:amount)
      [month_start.strftime('%b/%y'), revenue.to_f]
    end
  end
  
  def payment_methods_data
    orders = Order.all
    orders = orders.where(seller_id: [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]) if current_user.profile_id == 3
    
    OrderPayment.joins(:order, :order_payment_type)
                .where(orders: { id: orders.ids })
                .group('order_payment_types.payment_method')
                .count
                .map { |method, count| [method || 'Não definido', count] }
  end
  
  def orders_status_data
    orders = Order.all
    orders = orders.where(seller_id: [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]) if current_user.profile_id == 3
    
    [
      ['Integrados', orders.where.not(tiny_order_id: nil).count],
      ['Pendentes', orders.where(tiny_order_id: nil).count]
    ]
  end
end
