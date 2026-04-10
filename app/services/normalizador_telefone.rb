class NormalizadorTelefone
  # Normaliza um telefone para conter apenas dígitos.
  # Usado tanto antes de salvar quanto na verificação anti-duplicata,
  # para garantir que "(11) 99999-1234" e "11999991234" colidam.
  def self.call(valor)
    return nil if valor.blank?

    apenas_digitos = valor.to_s.gsub(/\D/, "")
    apenas_digitos.presence
  end
end
