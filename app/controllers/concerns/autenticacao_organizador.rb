module AutenticacaoOrganizador
  extend ActiveSupport::Concern

  included do
    helper_method :current_organizador, :organizador_logado?
  end

  def current_organizador
    return @current_organizador if defined?(@current_organizador)

    @current_organizador =
      if (id = session[:organizador_id])
        Organizador.find_by(id: id)
      end
  end

  def organizador_logado?
    current_organizador.present?
  end

  def login_organizador!(organizador)
    reset_session
    session[:organizador_id] = organizador.id
    @current_organizador = organizador
  end

  def logout_organizador!
    reset_session
    @current_organizador = nil
  end

  def requer_organizador!
    return if organizador_logado?

    flash[:alert] = "Faça login para continuar."
    redirect_to entrar_path
  end

  def requer_organizador_aprovado!
    requer_organizador!
    return unless current_organizador

    return if current_organizador.aprovado?

    redirect_to aguardando_aprovacao_path
  end
end
