class AprovacoesController < ApplicationController
  before_action :requer_organizador!

  # GET /aguardando-aprovacao
  def show
    redirect_to organizador_root_path if current_organizador.aprovado?
  end
end
