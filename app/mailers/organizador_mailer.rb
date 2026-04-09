class OrganizadorMailer < ApplicationMailer
  def redefinir_senha(organizador)
    @organizador = organizador
    @token = organizador.signed_id(purpose: :redefinir_senha, expires_in: 1.hour)
    @url = editar_senha_url(token: @token)

    mail(to: organizador.email, subject: "Redefinição de senha — Quiz")
  end
end
