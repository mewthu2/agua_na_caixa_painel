class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    redirect_to root_path, alert: 'Parâmetro não permitido.' unless ['primeiros_passos', 'agua_na_caixa'].include?(params[:origin])

    @products = Product.where(origin: params[:origin])
    
    # Filtrar por situação se fornecida
    @products = @products.where(situacao: params[:situacao]) if params[:situacao].present?
    
    # Filtrar por unidade se fornecida
    @products = @products.where(unidade: params[:unidade]) if params[:unidade].present?
    
    # Pesquisa por texto
    @products = @products.search(params[:search]) if params[:search].present?
    
    # Paginação
    @products = @products.paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @product = Product.new
    @product.origin = params[:origin]
    @product.situacao = 'A' # Define como ativo por padrão
  end

  def edit; end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path(origin: @product.origin), notice: 'Produto criado com sucesso.'
    else
      render :new, alert: @product.errors.full_messages.to_sentence
    end
  end

  def update
    if @product.update(product_params)
      redirect_to products_path(origin: @product.origin), notice: 'Produto atualizado com sucesso.'
    else
      render :edit, alert: @product.errors.full_messages.to_sentence
    end
  end

  def destroy
    origin = @product.origin
    @product.destroy
    redirect_to products_path(origin: origin), notice: 'Produto excluído com sucesso.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :origin,
      :data_criacao, 
      :nome, 
      :codigo, 
      :preco, 
      :preco_promocional, 
      :unidade, 
      :gtin, 
      :tipoVariacao, 
      :localizacao, 
      :preco_custo, 
      :preco_custo_medio, 
      :situacao
    )
  end
end
