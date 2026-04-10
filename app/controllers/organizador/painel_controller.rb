class Organizador::PainelController < Organizador::BaseController
  def show
    @quizzes_recentes = current_organizador.quizzes.order(created_at: :desc).limit(5)
    @campanhas_ativas = Campanha.joins(:quiz)
                                .where(quizzes: { organizador_id: current_organizador.id })
                                .where(status: "active")
                                .order(created_at: :desc)
                                .limit(5)
  end
end
