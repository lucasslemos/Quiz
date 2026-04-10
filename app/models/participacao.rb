class Participacao < ApplicationRecord
  belongs_to :campanha
  has_many :respostas, dependent: :destroy
  has_many :valores_campo_personalizado, dependent: :destroy

  validates :nome, presence: true
  validates :token_participante, presence: true, uniqueness: { scope: :campanha_id }

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
end
