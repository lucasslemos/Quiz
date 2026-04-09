class CadastrosController < ApplicationController
  def new
    @organizador = Organizador.new
  end

  def create
    @organizador = Organizador.new(cadastro_params)
    @organizador.status = "pending"

    if @organizador.save
      login_organizador!(@organizador)
      redirect_to aguardando_aprovacao_path,
                  notice: "Cadastro realizado! Aguarde a aprovação do administrador."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def cadastro_params
    params.require(:organizador).permit(:email, :password, :password_confirmation)
  end
end
