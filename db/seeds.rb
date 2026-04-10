# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ------------------------------------------------------------------------------
# Administrador inicial
# ------------------------------------------------------------------------------
# Email e senha vêm de variáveis de ambiente para não vazar credenciais.
# Em dev, defaults seguros pra desenvolvimento local.
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@quiz.local")
admin_senha = ENV.fetch("ADMIN_PASSWORD", "admin12345")

admin = Administrador.find_or_initialize_by(email: admin_email)
admin.password = admin_senha
admin.save!

puts "Administrador disponível: #{admin.email}"

# ------------------------------------------------------------------------------
# Organizador de desenvolvimento (apenas em dev/test)
# ------------------------------------------------------------------------------
# Em produção não criamos nenhum organizador automaticamente — eles se cadastram
# pelo /cadastro e o admin aprova. Em dev é prático ter um já aprovado para
# poder validar o fluxo do organizador sem precisar logar no /admin antes.
if Rails.env.local?
  organizador_email = ENV.fetch("ORGANIZADOR_DEV_EMAIL", "organizador@quiz.local")
  organizador_senha = ENV.fetch("ORGANIZADOR_DEV_PASSWORD", "organizador12345")

  organizador = Organizador.find_or_initialize_by(email: organizador_email)
  organizador.password = organizador_senha
  organizador.status = "approved"
  organizador.save!

  puts "Organizador de dev disponível (já aprovado): #{organizador.email} / #{organizador_senha}"
end
