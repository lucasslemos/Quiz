class OpcaoResposta < ApplicationRecord
  belongs_to :pergunta, inverse_of: :opcoes_resposta

  validates :texto, presence: true
end
