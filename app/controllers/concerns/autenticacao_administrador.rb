module AutenticacaoAdministrador
  extend ActiveSupport::Concern

  included do
    helper_method :current_administrador, :administrador_logado?
  end

  def current_administrador
    return @current_administrador if defined?(@current_administrador)

    @current_administrador =
      if (id = session[:administrador_id])
        Administrador.find_by(id: id)
      end
  end

  def administrador_logado?
    current_administrador.present?
  end

  def login_administrador!(administrador)
    reset_session
    session[:administrador_id] = administrador.id
    @current_administrador = administrador
  end

  def logout_administrador!
    reset_session
    @current_administrador = nil
  end

  def requer_administrador!
    return if administrador_logado?

    flash[:alert] = "Acesso restrito ao administrador."
    redirect_to admin_entrar_path
  end
end
