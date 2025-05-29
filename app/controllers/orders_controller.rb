class OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy]
  before_action :load_references, only: %i[new edit show update create]

  def integrate_orders
    order = Order.find(params[:order_id])
    result = CreateOrderJob.perform_now(order)

    case result
    when 2
      redirect_to orders_path, notice: 'Pedido já criado no Tiny, não é possível recriar.'
    when 3
      redirect_to orders_path, notice: 'Pedido criado com sucesso!'
    when 4
      redirect_to orders_path, alert: 'Aconteceu algum erro inesperado, por favor entre em contato com o suporte!'
    end
  end

  def tiny_orders
    redirect_to root_path, alert: 'Parâmetro não permitido.' unless %w[primeiros_passos agua_na_caixa].include?(params[:kinds])

    token = case params[:kinds]
            when 'primeiros_passos'
              ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')
            when 'agua_na_caixa'
              ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA')
            end

    @all_orders = fetch_all_orders(token)
  end

  def index
    @all_orders = Order.all
    @orders = Order.all

    if current_user.profile_id == 3
      seller_ids = [current_user.seller_id_primeiros_passos, current_user.seller_id_agua_na_caixa]

      @all_orders = @all_orders.where('user_id = :user_id OR seller_id IN (:seller_ids)', {
        user_id: current_user.id,
        seller_ids: seller_ids
      })

      @orders = @orders.where('user_id = :user_id OR seller_id IN (:seller_ids)', {
        user_id: current_user.id,
        seller_ids: seller_ids
      })
    end

    @orders = @orders.search(params[:search])
                    .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
                    .order('created_at DESC')
  end

  def show; end

  def new
    @order = Order.new
  end

  def edit
    if @order.destiny == 'primeiros_passos'
      @seller_primeiros_passos = Tiny::Sellers.search_sellers(ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS'))
    else
      @seller_agua_na_caixa = Tiny::Sellers.search_sellers(ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA'))
    end
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user

    if validate_amounts(params[:order]) && @order.save
      redirect_to orders_path, notice: 'Pedido criado com sucesso.'
    else
      render :edit
    end
  end

  def update
    if validate_amounts(params[:order]) && @order.update(order_params)
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

  def validate_amounts(order_params)
    product_amount = order_params[:order_products_attributes].values.sum do |op|
      quantidade = op['quantidade'].to_f
      preco = op['price'].to_f
      (quantidade * preco).round(2)
    end.round(2)

    order_payment_amount = order_params[:order_payments_attributes].values.sum do |op|
      op['amount'].to_f.round(2)
    end.round(2)

    if product_amount == order_payment_amount
      true
    else
      @order.errors.add(
        :base,
        "O valor total dos pagamentos (#{order_payment_amount}) deve ser igual ao valor total dos produtos (#{product_amount})."
      )
      false
    end
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :preference_payment,
      :contact_id,
      :use_contact_order,
      :tiny_order_id,
      :observation,
      :endereco,
      :numero,
      :complemento,
      :bairro,
      :cep,
      :uf,
      :seller_id,
      :seller_name,
      order_products_attributes: [:id, :product_id, :quantidade, :price, :_destroy],
      order_payments_attributes: [:id, :order_payment_type_id, :date, :note, :amount, :_destroy]
    )
  end

  def load_references
    @products = Product.all
    @payment_types = OrderPaymentType.all
    @contacts = Contact.distinct(:cpf_cnpj)
  end

  def fetch_all_orders(token)
    orders = Tiny::Orders.get_all_orders('', token)

    return orders[:pedidos] unless orders[:numero_paginas].present? && orders[:numero_paginas] != 1 && orders['pedidos'].present?

    all_orders = []
    orders[:numero_paginas].times do
      page_orders = Tiny::Orders.get_orders('', 1, token)
      page_orders[:pedidos].each do |order|
        all_orders << order
      end
    end

    all_orders
  end
end
