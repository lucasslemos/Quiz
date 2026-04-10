class Campanha < ApplicationRecord
  STATUSES = %w[draft active closed].freeze

  belongs_to :quiz
  has_many :participacoes, dependent: :destroy

  validates :nome, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "deve conter apenas letras minúsculas, números e hífens" }
  validates :status, inclusion: { in: STATUSES }

  before_validation :gerar_slug, on: :create

  scope :ativas, -> { where(status: "active") }

  def draft?  = status == "draft"
  def active? = status == "active"
  def closed? = status == "closed"

  def ativar!  = update!(status: "active")
  def encerrar! = update!(status: "closed")

  def tem_participacoes?
    participacoes.exists?
  end

  private

  def gerar_slug
    return if slug.present?

    base = nome.to_s.parameterize.presence || "campanha"
    candidato = base
    sufixo = 0
    while self.class.where(slug: candidato).exists?
      sufixo += 1
      candidato = "#{base}-#{SecureRandom.hex(2)}"
      break if sufixo > 5
    end
    self.slug = candidato
  end
end
