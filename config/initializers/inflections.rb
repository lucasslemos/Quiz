# Be sure to restart your server when you modify this file.

# Inflexões em Português do Brasil para os nomes de domínio do projeto.
# Permitem que models/controllers/services tenham nomes em pt-BR sem precisar
# declarar `self.table_name` ou pluralização manual a cada classe nova.
#
# As regras são registradas no inflector padrão (`:en`) porque é ele que o
# Zeitwerk usa para resolver constantes <-> arquivos. O `I18n.default_locale`
# do app continua sendo `:"pt-BR"` (ver `config/application.rb`).
ActiveSupport::Inflector.inflections(:en) do |inflect|
  # ----------------------------------------------------------------------------
  # Regras gerais de plural em pt-BR
  # ----------------------------------------------------------------------------
  # Palavras terminadas em "ão" -> "ões" (participação -> participações,
  # opção -> opções, configuração -> configurações). Sem acento porque
  # nomes de classe/arquivo não devem ter caracteres acentuados.
  inflect.plural(/ao$/i, "oes")
  inflect.singular(/oes$/i, "ao")

  # Terminadas em "r", "z", "n" -> "+es" (organizador -> organizadores,
  # administrador -> administradores)
  inflect.plural(/([rzn])$/i, '\1es')
  inflect.singular(/([rzn])es$/i, '\1')

  # Terminadas em "al", "el", "ol", "ul" -> "ais", "eis", "ois", "uis"
  inflect.plural(/al$/i, "ais")
  inflect.plural(/el$/i, "eis")
  inflect.plural(/ol$/i, "ois")
  inflect.plural(/ul$/i, "uis")
  inflect.singular(/ais$/i, "al")
  inflect.singular(/eis$/i, "el")
  inflect.singular(/ois$/i, "ol")
  inflect.singular(/uis$/i, "ul")

  # ----------------------------------------------------------------------------
  # Irregulares conhecidos do domínio Quiz
  # ----------------------------------------------------------------------------
  inflect.irregular("organizador",               "organizadores")
  inflect.irregular("administrador",             "administradores")
  inflect.irregular("pergunta",                  "perguntas")
  inflect.irregular("resposta",                  "respostas")
  inflect.irregular("campanha",                  "campanhas")
  inflect.irregular("participante",              "participantes")
  inflect.irregular("participacao",              "participacoes")
  inflect.irregular("opcao_resposta",            "opcoes_resposta")
  inflect.irregular("campo_personalizado",       "campos_personalizados")
  inflect.irregular("valor_campo_personalizado", "valores_campo_personalizado")
end
