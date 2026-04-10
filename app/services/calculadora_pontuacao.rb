class CalculadoraPontuacao
  def self.call(participacao)
    respostas = participacao.respostas.includes(:opcao_resposta).to_a
    total_perguntas = participacao.campanha.quiz.perguntas.count

    acertos = respostas.count { |r| r.opcao_resposta&.correta? }
    tempo_total = respostas.sum { |r| r.tempo_resposta_ms.to_i }

    participacao.update!(
      pontuacao: acertos,
      tempo_total_ms: tempo_total,
      vencedor: acertos == total_perguntas && total_perguntas > 0,
      enviado_em: Time.current
    )
  end
end
