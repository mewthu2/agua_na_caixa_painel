class OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy]
  before_action :load_references, only: %i[new edit show update]

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
    @orders = Order.search(params[:search])
                   .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @order = Order.new
  end

  def edit; end

  def create
    @order = Order.new(order_params)

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
      product = Product.find(op['product_id'])
      quantidade * product.preco
    end

    order_payment_amount = order_params[:order_payments_attributes].values.sum { |op| op['amount'].to_f }

    return true if product_amount == order_payment_amount

    @order.errors.add(:base, "O valor total dos pagamentos (#{order_payment_amount}) deve ser igual ao valor total dos produtos (#{product_amount}).")
    false
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
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
      order_products_attributes: [:id, :product_id, :quantidade, :price, :_destroy],
      order_payments_attributes: [:id, :order_payment_type_id, :date, :note, :amount, :_destroy]
    )
  end

  def load_references
    @products = Product.where(id: [699209952,
                                   748360188,
                                   744662967,
                                   752754424,
                                   753265993,
                                   754738936,
                                   754742848,
                                   590475173,
                                   754447889,
                                   726141299,
                                   742667645,
                                   753544247,
                                   754393155,
                                   726142138,
                                   754778220,
                                   726141666,
                                   752764639,
                                   752764722,
                                   755259574,
                                   747561604,
                                   755259571,
                                   747560612,
                                   747561660,
                                   755259581,
                                   747561649,
                                   755259577])
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
