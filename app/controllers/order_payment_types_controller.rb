class OrderPaymentTypesController < ApplicationController
  before_action :set_order_payment_type, only: %i[show edit update destroy]

  def index
    @order_payment_types = OrderPaymentType.search(params[:search])
                                           .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @order_payment_type = OrderPaymentType.new
  end

  def edit; end

  def create
    @order_payment_type = OrderPaymentType.new(order_payment_type_params)
    if @order_payment_type.save
      redirect_to order_payment_types_path, notice: 'Tipo de pagamento do pedido criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @order_payment_type.update(order_payment_type_params)
      redirect_to order_payment_types_path, notice: 'Tipo de pagamento do pedido atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @order_payment_type.destroy
    redirect_to order_payment_types_path, notice: 'Tipo de pagamento do pedido excluído com sucesso.'
  end

  private

  def set_order_payment_type
    @order_payment_type = OrderPaymentType.find(params[:id])
  end

  def order_payment_type_params
    params.require(:order_payment_type).permit(:note, :payment_method, :payment_channel)
  end
end
