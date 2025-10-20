class OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy fetch_invoice_pdf]
  before_action :load_references, only: %i[new edit show update create]

  def integrate_orders
    order = Order.find(params[:order_id])

    contact = order.contact
    if contact.blank? || contact.email.blank?
      redirect_to orders_path, alert: 'Não é possível integrar o pedido. O cliente não possui e-mail cadastrado. Por favor, atualize o cadastro do cliente antes de integrar.' and return
    end

    result = CreateOrderJob.perform_now(order)

    case result
    when 2
      redirect_to orders_path, notice: 'Pedido já criado no Tiny, não é possível recriar.'
    when 3
      redirect_to orders_path, notice: 'Pedido criado com sucesso!'
    when 4
      redirect_to orders_path, alert: 'Aconteceu algum erro inesperado, por favor entre em contato com o suporte!'
    when 5
      redirect_to orders_path, alert: 'Erro na integração: E-mail do cliente não encontrado. Por favor, atualize o cadastro do cliente.'
    else
      redirect_to orders_path, alert: 'Erro desconhecido na integração. Por favor, entre em contato com o suporte.'
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
        seller_ids:
      })

      @orders = @orders.where('user_id = :user_id OR seller_id IN (:seller_ids)', {
        user_id: current_user.id,
        seller_ids:
      })
    end

    @orders = @orders.where(seller_name: params[:seller])  if params[:seller].present?

    if params[:status].present?
      case params[:status]
      when 'integrated'
        @orders = @orders.where.not(tiny_order_id: nil)
      when 'not_integrated', 'pending'
        @orders = @orders.where(tiny_order_id: nil)
      end
    end

    if params[:date].present?
      case params[:date]
      when 'today'
        @orders = @orders.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
      end
    end

    @orders = @orders.search(params[:search]) if params[:search].present?

    @orders = @orders.paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
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

  def fetch_invoice_pdf
    unless @order.id_nota_fiscal.present?
      render json: { error: 'Pedido não possui ID de nota fiscal' }, status: :unprocessable_entity
      return
    end

    if @order.xml_nota_fiscal.blank?
      FetchInvoiceXmlJob.perform_now(@order.id)
      @order.reload
    end

    if @order.xml_nota_fiscal.present?
      pdf_content = generate_pdf_from_xml(@order.xml_nota_fiscal)

      send_data pdf_content, filename: "nota_fiscal_#{@order.id_nota_fiscal}.pdf",
                             type: 'application/pdf',
                             disposition: 'inline'
    else
      render json: { error: 'Não foi possível obter o XML da nota fiscal' }, status: :unprocessable_entity
    end
  end

  private

  def validate_amounts(order_params)
    product_amount = order_params[:order_products_attributes].values.sum do |op|
      quantidade = op['quantidade'].to_f
      preco = op['price'].to_f
      (quantidade * preco).round(2)
    end.round(2)
    order_payment_amount = order_params[:order_payments_attributes].values.sum { |op| op['amount'].to_f }.round(2)

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
      :receiving_time,
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

  def generate_pdf_from_xml(xml_content)
    require 'prawn'

    Prawn::Document.new do |pdf|
      pdf.text 'NOTA FISCAL ELETRÔNICA', size: 20, style: :bold, align: :center
      pdf.move_down 20

      begin
        doc = Nokogiri::XML(xml_content)

        pdf.text "Número: #{doc.xpath('//nNF').text}", size: 14
        pdf.text "Série: #{doc.xpath('//serie').text}", size: 14
        pdf.text "Data de Emissão: #{doc.xpath('//dhEmi').text}", size: 14
        pdf.move_down 20

        pdf.text 'EMITENTE', size: 16, style: :bold
        pdf.text "Nome: #{doc.xpath('//emit/xNome').text}"
        pdf.text "CNPJ: #{doc.xpath('//emit/CNPJ').text}"
        pdf.text "Endereço: #{doc.xpath('//emit/enderEmit/xLgr').text}, #{doc.xpath('//emit/enderEmit/nro').text}"
        pdf.text "Cidade: #{doc.xpath('//emit/enderEmit/xMun').text} - #{doc.xpath('//emit/enderEmit/UF').text}"
        pdf.move_down 20

        pdf.text 'DESTINATÁRIO', size: 16, style: :bold
        pdf.text "Nome: #{doc.xpath('//dest/xNome').text}"
        cpf_cnpj = doc.xpath('//dest/CNPJ').text.presence || doc.xpath('//dest/CPF').text
        pdf.text "CPF/CNPJ: #{cpf_cnpj}"
        pdf.text "Endereço: #{doc.xpath('//dest/enderDest/xLgr').text}, #{doc.xpath('//dest/enderDest/nro').text}"
        pdf.text "Cidade: #{doc.xpath('//dest/enderDest/xMun').text} - #{doc.xpath('//dest/enderDest/UF').text}"
        pdf.move_down 20

        pdf.text 'PRODUTOS/SERVIÇOS', size: 16, style: :bold

        items_data = []
        items_data << ['Código', 'Descrição', 'Qtd', 'Valor Unit.', 'Total']

        doc.xpath('//det').each do |item|
          items_data << [
            item.xpath('prod/cProd').text,
            item.xpath('prod/xProd').text,
            item.xpath('prod/qCom').text,
            "R$ #{item.xpath('prod/vUnCom').text}",
            "R$ #{item.xpath('prod/vProd').text}"
          ]
        end

        pdf.table(items_data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
          cells.padding = 5
          cells.borders = [:top, :bottom, :left, :right]
        end

        pdf.move_down 20

        total = doc.xpath('//ICMSTot/vNF').text
        pdf.text "VALOR TOTAL: R$ #{total}", size: 16, style: :bold, align: :right

      rescue StandardError => e
        pdf.text "Erro ao processar XML: #{e.message}"
        pdf.move_down 10
        pdf.text 'XML Bruto:', style: :bold
        pdf.text xml_content, size: 8
      end
    end.render
  end
end
