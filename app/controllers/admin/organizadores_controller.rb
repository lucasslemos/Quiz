class Admin::OrganizadoresController < Admin::BaseController
  before_action :buscar_organizador, only: %i[aprovar rejeitar suspender]

  # GET /admin/organizadores
  def index
    @status = params[:status].presence_in(Organizador::STATUSES) || "all"
    @organizadores =
      if @status == "all"
        Organizador.order(created_at: :desc)
      else
        Organizador.where(status: @status).order(created_at: :desc)
      end
  end

  # GET /admin/organizadores/pendentes
  def pendentes
    @organizadores = Organizador.pendentes.order(created_at: :asc)
    render :pendentes
  end

  def aprovar
    @organizador.aprovar!
    redirect_back fallback_location: pendentes_admin_organizadores_path,
                  notice: "Organizador aprovado."
  end

  def rejeitar
    @organizador.rejeitar!
    redirect_back fallback_location: pendentes_admin_organizadores_path,
                  notice: "Organizador rejeitado."
  end

  def suspender
    @organizador.suspender!
    redirect_back fallback_location: admin_organizadores_path,
                  notice: "Organizador suspenso."
  end

  private

  def buscar_organizador
    @organizador = Organizador.find(params[:id])
  end
end
