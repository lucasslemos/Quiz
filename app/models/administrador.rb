class Administrador < ApplicationRecord
  has_secure_password

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  before_validation :normalizar_email

  private

  def normalizar_email
    self.email = email.to_s.strip.downcase.presence
  end
end
