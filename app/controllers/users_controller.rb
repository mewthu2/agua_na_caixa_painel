class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]
  before_action :load_refferences, only: %i[show edit new]

  def index
    @users = User.paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'Usuário criado com sucesso.'
    else
      redirect_to @user, alert: "Erro na atualização de usuário: #{@user.errors.full_messages.to_sentence}"
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'Usuário atualizado com sucesso.'
    else
      redirect_to users_path, alert: "Erro na atualização de usuário: #{@user.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'Usuário excluído com sucesso.'
  end

  private

  def load_refferences
    @profiles = Profile.all
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name,
                                 :email,
                                 :password,
                                 :password_confirmation,
                                 :profile_id,
                                 :seller_id_primeiros_passos,
                                 :seller_id_agua_na_caixa)
  end
end
