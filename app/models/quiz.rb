class Quiz < ApplicationRecord
  ESTADOS_IDENTIFICADOR = %w[not_asked optional required].freeze

  belongs_to :organizador
  has_many :perguntas, -> { order(:posicao, :id) }, dependent: :destroy
  has_many :campos_personalizados, -> { order(:posicao, :id) }, dependent: :destroy
  has_many :campanhas, dependent: :destroy

  validates :titulo, presence: true
  validates :email_state, inclusion: { in: ESTADOS_IDENTIFICADOR }
  validates :phone_state, inclusion: { in: ESTADOS_IDENTIFICADOR }

  def identificadores_fracos?
    email_state != "required" && phone_state != "required"
  end
end
