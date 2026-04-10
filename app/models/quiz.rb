class Quiz < ApplicationRecord
  ESTADOS_IDENTIFICADOR = %w[not_asked optional required].freeze

  belongs_to :organizador
  has_many :perguntas, -> { order(:posicao, :id) }, dependent: :destroy
  has_many :campos_personalizados, -> { order(:posicao, :id) }, dependent: :destroy
  has_many :campanhas, dependent: :destroy

  validates :titulo, presence: true
  validates :email_state, inclusion: { in: ESTADOS_IDENTIFICADOR }
  validates :phone_state, inclusion: { in: ESTADOS_IDENTIFICADOR }
  validates :tempo_por_pergunta, numericality: { only_integer: true, greater_than_or_equal_to: 5, less_than_or_equal_to: 300 }

  def identificadores_fracos?
    email_state != "required" && phone_state != "required"
  end
end
