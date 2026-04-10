class CampoPersonalizado < ApplicationRecord
  TIPOS = %w[text email phone select].freeze

  belongs_to :quiz

  validates :rotulo, presence: true
  validates :tipo_campo, inclusion: { in: TIPOS }
  validate :opcoes_obrigatorias_para_select

  private

  def opcoes_obrigatorias_para_select
    return unless tipo_campo == "select"
    return if opcoes.is_a?(Array) && opcoes.any?

    errors.add(:opcoes, "campo do tipo select precisa de pelo menos uma opção")
  end
end
