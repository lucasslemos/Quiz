require "csv"

class ExportadorCsvCampanha
  def initialize(campanha)
    @campanha = campanha
    @quiz = campanha.quiz
    @campos = @quiz.campos_personalizados.to_a
  end

  def gerar
    CSV.generate(headers: true) do |csv|
      csv << cabecalho
      @campanha.participacoes
               .includes(valores_campo_personalizado: :campo_personalizado)
               .order(:created_at)
               .each do |p|
        csv << linha(p)
      end
    end
  end

  def nome_arquivo
    "campanha-#{@campanha.slug}-#{Date.current.strftime('%Y%m%d')}.csv"
  end

  private

  def cabecalho
    %w[nome email telefone] + @campos.map(&:rotulo) + %w[pontuacao vencedor enviado_em]
  end

  def linha(participacao)
    valores = participacao.valores_campo_personalizado.index_by(&:campo_personalizado_id)
    [
      participacao.nome,
      participacao.email,
      participacao.telefone,
      *@campos.map { |c| valores[c.id]&.valor },
      participacao.pontuacao,
      participacao.vencedor? ? "sim" : "nao",
      participacao.enviado_em&.iso8601
    ]
  end
end
