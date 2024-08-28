class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    redirect_to root_path, alert: 'Parâmetro não permitido.' unless ['primeiros_passos', 'agua_na_caixa'].include?(params[:origin])

    @contacts = Contact.where(origin: params[:origin])
                       .search(params[:search])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @contact = Contact.new
  end

  def edit; end

  def create
    @contact = Contact.new(profile_params)
    if @contact.save
      redirect_to profiles_path, notice: 'Contato criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @contact.update(profile_params)
      redirect_to profiles_path, notice: 'Contato atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy
    redirect_to profiles_path, notice: 'Contato excluído com sucesso.'
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name)
  end
end
