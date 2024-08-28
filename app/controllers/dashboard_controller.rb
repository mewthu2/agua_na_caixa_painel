class DashboardController < ApplicationController
  before_action :load_form_references, only: [:index]

  def index; end

  def to_do
    previous_url = request.referer || root_path
    redirect_to root_path, notice: "Função não implementada. <a href='#{previous_url}' class='btn btn-sm btn-primary'>Voltar</a>".html_safe
  end

  private

  def load_form_references; end
end
