class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    redirect_to root_path, alert: 'Parâmetro não permitido.' unless ['primeiros_passos', 'agua_na_caixa'].include?(params[:origin])

    @products = Product.where(origin: params[:origin])
                       .search(params[:search])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: 'Produto criado com sucesso.'
    else
      redirect_to new_product_path, alert: @product.errors.full_messages.to_sentence
    end
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: 'Produto atualizado com sucesso.'
    else
      redirect_to edit_product_path(@product), alert: @product.errors.full_messages.to_sentence
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Produto excluído com sucesso.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:data_criacao, :nome, :codigo, :preco, :preco_promocional, :unidade, :gtin, :tipoVariacao, :localizacao, :preco_custo, :preco_custo_medio, :situacao)
  end
end
