class SenhasController < ApplicationController
  # GET /senha/nova
  def new
  end

  # POST /senha
  def create
    organizador = Organizador.find_by(email: params[:email].to_s.strip.downcase)
    OrganizadorMailer.redefinir_senha(organizador).deliver_later if organizador

    redirect_to entrar_path,
                notice: "Se o email existir, enviaremos instruções para redefinir a senha."
  end

  # GET /senha/editar?token=...
  def edit
    @organizador = organizador_pelo_token
    redirect_to entrar_path, alert: "Link inválido ou expirado." unless @organizador
  end

  # PATCH/PUT /senha
  def update
    @organizador = organizador_pelo_token

    return redirect_to(entrar_path, alert: "Link inválido ou expirado.") unless @organizador

    if @organizador.update(senha_params)
      redirect_to entrar_path, notice: "Senha redefinida. Faça login novamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organizador_pelo_token
    Organizador.find_signed(params[:token], purpose: :redefinir_senha)
  end

  def senha_params
    params.require(:organizador).permit(:password, :password_confirmation)
  end
end
