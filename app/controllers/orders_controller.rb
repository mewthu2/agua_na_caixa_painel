class OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy]
  before_action :load_form_references, only: [:index]

  def index
    @orders = Order.search(params[:search])
                   .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def search_contacts
    Contact.search(params[:search])
  end

  def tiny_orders
    redirect_to root_path, alert: 'Parâmetro não permitido.' unless ['primeiros_passos', 'agua_na_caixa'].include?(params[:kinds])

    case params[:kinds]
    when 'primeiros_passos'
      token = ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
    when 'agua_na_caixa'
      token = ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA')
    end

    @all_orders = fetch_all_orders(token)
  end

  def show; end

  def new
    @order = Order.new
  end

  def edit; end

  def create
    @order = Order.new(order_params)
    if @order.save
      redirect_to orders_path, notice: 'Pedido criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @order.update(order_params)
      redirect_to orders_path, notice: 'Pedido atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: 'Pedido excluído com sucesso.'
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:destiny)
  end

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
