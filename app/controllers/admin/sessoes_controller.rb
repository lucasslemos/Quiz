class Admin::SessoesController < ApplicationController
  include AutenticacaoAdministrador

  layout "admin"

  def new
    redirect_to admin_organizadores_path if administrador_logado?
  end

  def create
    administrador = Administrador.find_by(email: params[:email].to_s.strip.downcase)

    if administrador&.authenticate(params[:password])
      login_administrador!(administrador)
      redirect_to admin_organizadores_path, notice: "Bem-vindo, administrador."
    else
      flash.now[:alert] = "Email ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout_administrador!
    redirect_to admin_entrar_path, notice: "Você saiu."
  end
end
