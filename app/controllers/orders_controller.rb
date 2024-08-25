class OrdersController < ApplicationController
  before_action :load_form_references, only: [:index]

  def index
    case params[:kinds]
    when 'show_orders_primeiros_passos'
      token = ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
    when 'show_orders_agua_na_caixa'
      token = ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA')
    else
      redirect_to root_path, alert: 'Parâmetro não permitido.'
    end

    @all_orders = fetch_all_orders(token)
  end

  private

  def load_form_references; end

  def fetch_all_orders(token)
    orders = Tiny::Orders.get_all_orders('', token)

    return orders[:pedidos] unless orders[:numero_paginas].present? && orders[:numero_paginas] != 1 && orders['pedidos'].present?

    all_orders = []
    orders[:numero_paginas].times do |page|
      page_orders = Tiny::Orders.get_orders('', 1, token)
      page_orders[:pedidos].each do |order|
        all_orders << order
      end
    end

    all_orders
  end
end
