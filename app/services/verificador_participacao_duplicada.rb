class VerificadorParticipacaoDuplicada
  # Verifica se já existe Participacao para a Campanha em qualquer das camadas:
  #   1) cookie token (mais forte: navegador específico)
  #   2) email case-insensitive (se preenchido)
  #   3) telefone normalizado (se preenchido)
  def self.duplicada?(campanha, cookie_token:, email:, telefone:)
    participacoes = campanha.participacoes

    if cookie_token.present? && participacoes.where(token_participante: cookie_token).exists?
      return true
    end

    email_normalizado = email.to_s.strip.downcase.presence
    if email_normalizado && participacoes.where(email: email_normalizado).exists?
      return true
    end

    telefone_normalizado = NormalizadorTelefone.call(telefone)
    if telefone_normalizado && participacoes.where(telefone: telefone_normalizado).exists?
      return true
    end

    false
  end
end
