class Organizador::ParticipacoesController < Organizador::BaseController
  before_action :carregar_campanha

  def index
    @participacoes = @campanha.participacoes
                              .includes(valores_campo_personalizado: :campo_personalizado)
                              .order(created_at: :desc)
    @campos = @quiz.campos_personalizados
  end

  def vencedores
    @participacoes = @campanha.participacoes
                              .where(vencedor: true)
                              .includes(valores_campo_personalizado: :campo_personalizado)
                              .order(enviado_em: :desc)
    @campos = @quiz.campos_personalizados
    render :index
  end

  private

  def carregar_campanha
    @quiz = current_organizador.quizzes.find(params[:quiz_id])
    @campanha = @quiz.campanhas.find(params[:campanha_id])
  end
end
