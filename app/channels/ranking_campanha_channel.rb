class RankingCampanhaChannel < ApplicationCable::Channel
  def subscribed
    campanha = Campanha.find_by(id: params[:campanha_id])

    if campanha && autorizado?(campanha)
      stream_from "ranking_campanha_#{campanha.id}"
    else
      reject
    end
  end

  def self.transmitir_para(campanha)
    participacoes = campanha.participacoes.ranking.limit(50)

    Turbo::StreamsChannel.broadcast_replace_to(
      "ranking_campanha_#{campanha.id}",
      target: "tabela-ranking",
      partial: "organizador/participacoes/tabela_ranking",
      locals: { participacoes: participacoes, campanha: campanha }
    )
  end

  private

  def autorizado?(campanha)
    current_organizador&.id == campanha.quiz.organizador_id
  end
end
