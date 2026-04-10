class Pergunta < ApplicationRecord
  belongs_to :quiz
  has_many :opcoes_resposta, -> { order(:posicao, :id) }, dependent: :destroy, inverse_of: :pergunta

  accepts_nested_attributes_for :opcoes_resposta, allow_destroy: true, reject_if: :all_blank

  validates :texto, presence: true
  validate :ao_menos_duas_opcoes
  validate :exatamente_uma_correta

  private

  def ao_menos_duas_opcoes
    return if opcoes_resposta.reject(&:marked_for_destruction?).size >= 2

    errors.add(:base, "A pergunta precisa ter pelo menos duas opções de resposta")
  end

  def exatamente_uma_correta
    corretas = opcoes_resposta.reject(&:marked_for_destruction?).count(&:correta)
    return if corretas == 1

    errors.add(:base, "A pergunta precisa ter exatamente uma opção correta")
  end
end
