class Organizador < ApplicationRecord
  has_secure_password

  STATUSES = %w[pending approved rejected suspended].freeze

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :status, inclusion: { in: STATUSES }

  before_validation :normalizar_email

  scope :pendentes,   -> { where(status: "pending") }
  scope :aprovados,   -> { where(status: "approved") }
  scope :rejeitados,  -> { where(status: "rejected") }
  scope :suspensos,   -> { where(status: "suspended") }

  def pendente?    = status == "pending"
  def aprovado?    = status == "approved"
  def rejeitado?   = status == "rejected"
  def suspenso?    = status == "suspended"

  def aprovar!     = update!(status: "approved")
  def rejeitar!    = update!(status: "rejected")
  def suspender!   = update!(status: "suspended")

  private

  def normalizar_email
    self.email = email.to_s.strip.downcase.presence
  end
end
