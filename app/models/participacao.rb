class Participacao < ApplicationRecord
  belongs_to :campanha
  has_many :respostas, dependent: :destroy
  has_many :valores_campo_personalizado, dependent: :destroy

  validates :nome, presence: true
  validates :token_participante, presence: true, uniqueness: { scope: :campanha_id }

  scope :ranking, -> { where.not(enviado_em: nil).order(pontuacao: :desc, tempo_total_ms: :asc) }

  after_commit :transmitir_ranking, if: :saved_change_to_enviado_em?

  before_validation :normalizar_email
  before_validation :normalizar_telefone
  before_validation :gerar_token

  private

  def normalizar_email
    self.email = email.to_s.strip.downcase.presence
  end

  def normalizar_telefone
    self.telefone = NormalizadorTelefone.call(telefone)
  end

  def gerar_token
    self.token_participante ||= SecureRandom.hex(16)
  end

  def finalizada?
    enviado_em.present?
  end

  def transmitir_ranking
    RankingCampanhaChannel.transmitir_para(campanha) if defined?(RankingCampanhaChannel)
  end
end
