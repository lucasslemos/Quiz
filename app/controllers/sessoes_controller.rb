class SessoesController < ApplicationController
  def new
    redirect_to organizador_root_path if organizador_logado?
  end

  def create
    organizador = Organizador.find_by(email: params[:email].to_s.strip.downcase)

    if organizador&.authenticate(params[:password])
      case organizador.status
      when "approved", "pending"
        login_organizador!(organizador)
        redirect_to organizador_root_path, notice: "Bem-vindo!"
      when "rejected"
        flash.now[:alert] = "Seu cadastro foi recusado. Entre em contato com o administrador."
        render :new, status: :unprocessable_entity
      when "suspended"
        flash.now[:alert] = "Sua conta está suspensa. Entre em contato com o administrador."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Email ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout_organizador!
    redirect_to entrar_path, notice: "Você saiu."
  end
end
