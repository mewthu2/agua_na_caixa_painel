class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show edit update destroy]
  before_action :load_references, only: %i[show edit]
  def index
    redirect_to root_path, alert: 'Parâmetro não permitido.' unless ['primeiros_passos', 'agua_na_caixa'].include?(params[:origin])

    @contacts = Contact.where(origin: params[:origin])
                       .search(params[:search])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show
    @all_contact_orders = fetch_all_contact_orders
  end

  def new
    @contact = Contact.new
  end

  def edit
    @all_contact_orders = fetch_all_contact_orders
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to contacts_path(origin: @contact.origin), notice: 'Contato criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to contacts_path(origin: @contact.origin), notice: 'Contato atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path(origin: @contact.origin), notice: 'Contato excluído com sucesso.'
  end

  def fetch_all_contact_orders
    token = @contact.origin == 'agua_na_caixa' ? ENV.fetch('TOKEN_TINY_AGUA_NA_CAIXA') : ENV.fetch('TOKEN_TINY_PRIMEIROS_PASSOS')

    orders = Tiny::Orders.get_contact_orders('', token, @contact.nome)

    return orders[:pedidos] if orders[:numero_paginas].present? && orders[:numero_paginas] == 1 && orders['pedidos'].present?

    all_orders = []
    orders[:numero_paginas].to_i.times do |page|
      page_orders = Tiny::Orders.get_orders('', page + 1, token)
      all_orders.concat(page_orders[:pedidos]) if page_orders[:pedidos].present?
    end

    all_orders
  end

  private

  def load_references
    @order_payment_types = OrderPaymentType.all
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :order_payment_type_id,
      :origin,
      :segment,
      :codigo,
      :nome,
      :fantasia,
      :tipo_pessoa,
      :cpf_cnpj,
      :endereco,
      :numero,
      :complemento,
      :bairro,
      :cep,
      :cidade,
      :uf,
      :email,
      :email_nota_fiscal,
      :fone,
      :id_lista_preco,
      :id_vendedor,
      :nome_vendedor,
      :nome_responsavel_tel,
      :situacao,
      :data_criacao
    )
  end
end
