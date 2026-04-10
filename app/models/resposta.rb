class Resposta < ApplicationRecord
  belongs_to :participacao
  belongs_to :pergunta
  belongs_to :opcao_resposta

  validates :pergunta_id, uniqueness: { scope: :participacao_id }

  def correta?
    opcao_resposta&.correta?
  end
end
