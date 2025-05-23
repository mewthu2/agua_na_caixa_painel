class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show edit update destroy]

  def index
    @all_profiles = Profile.all
    @profiles = Profile.search(params[:search])
                      .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def show; end

  def new
    @profile = Profile.new
  end

  def edit; end

  def create
    @profile = Profile.new(profile_params)
    if @profile.save
      redirect_to profiles_path, notice: 'Perfil criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to profiles_path, notice: 'Perfil atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: 'Perfil excluído com sucesso.'
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name)
  end
end
