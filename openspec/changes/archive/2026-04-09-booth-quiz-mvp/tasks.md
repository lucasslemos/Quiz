## 1. Setup do projeto

- [x] 1.1 Bootstrap 5 já configurado via `cssbundling-rails` (travado pela spec `ui-layout`); nenhuma ação adicional necessária
- [x] 1.2 Adicionar gem `rqrcode` ao Gemfile (também adicionado `bcrypt` e `letter_opener`)
- [x] 1.3 Configurar locale pt-BR como padrão (`config.i18n.default_locale = :"pt-BR"`) — já feito em `lock-stack-bootstrap5`
- [x] 1.4 Banco de dados MySQL (gem `mysql2`) já configurado em todos os ambientes (travado pela spec `project-stack`); nenhuma ação adicional necessária
- [x] 1.5 Criar layouts base separados: `application.html.erb` (organizador, já existente com Bootstrap 5), `admin.html.erb`, `participante.html.erb` (minimalista, usando Bootstrap 5)

## 2. Modelo de dados — Organizador e Administrador

- [x] 2.1 Gerar model `Organizador` (tabela `organizadores`) com campos: email (unique), password_digest, status (enum: pending/approved/rejected/suspended), timestamps
- [x] 2.2 Gerar model `Administrador` (tabela `administradores`) com campos: email (unique), password_digest, timestamps
- [x] 2.3 Migrations + índices únicos em email
- [x] 2.4 Validações de modelo (email formato, senha mínimo 8 chars)
- [x] 2.5 Seed de pelo menos um Administrador inicial via `db/seeds.rb` ou rake task

## 3. Autenticação do organizador

- [x] 3.1 Auth manual com `has_secure_password` (não usei o gerador `rails g authentication` porque temos dois contextos de auth distintos — Organizador e Administrador — e duplicar/adaptar o gerador sairia mais caro que escrever do zero)
- [x] 3.2 Rotas: `/cadastro`, `/entrar`, `/sair`, `/senha/nova`, `/senha/editar`
- [x] 3.3 Tela de "aguardando aprovação" exibida para organizadores `pending`/`rejected`/`suspended`
- [x] 3.4 Concern `AutenticacaoOrganizador` com helper `requer_organizador_aprovado!` (substitui `RequerOrganizadorAprovado` da spec)
- [x] 3.5 Mensagens claras para `rejected` e `suspended` no login
- [x] 3.6 Fluxo de recuperação de senha por email com token assinado (`signed_id` purpose `:redefinir_senha`, expira em 1h); mailer `OrganizadorMailer#redefinir_senha` com `letter_opener` em dev

## 4. Autenticação do administrador e painel

- [x] 4.1 Sessão de administrador separada (controllers em namespace `Admin::`, concern `AutenticacaoAdministrador`)
- [x] 4.2 Rotas `/admin/entrar`, `/admin/sair`
- [x] 4.3 Concern `AutenticacaoAdministrador` com `requer_administrador!` (substitui `RequerAdministrador` da spec)
- [x] 4.4 Página `/admin/organizadores` com filtro por status (todos/pending/approved/rejected/suspended)
- [x] 4.5 Página `/admin/organizadores/pendentes` com fila e ações aprovar/rejeitar
- [x] 4.6 Ações `aprovar`, `rejeitar` e `suspender` mudando o status do `Organizador`

## 5. Modelo de dados — Quiz e perguntas

- [x] 5.1 Model `Quiz` (organizador_id, titulo, configs de identificador como colunas: email_state, phone_state) — manter `Quiz` em inglês (nome do app/domínio); inflexão `quiz`/`quizzes` adicionada em `config/initializers/inflections.rb`
- [x] 5.2 Model `Pergunta` (tabela `perguntas`) (quiz_id, texto, posicao)
- [x] 5.3 Model `OpcaoResposta` (tabela `opcoes_resposta`) (pergunta_id, texto, correta boolean, posicao)
- [x] 5.4 Model `CampoPersonalizado` (tabela `campos_personalizados`) (quiz_id, rotulo, tipo_campo enum, obrigatorio, opcoes JSON, posicao)
- [x] 5.5 Migrations + foreign keys + índices
- [x] 5.6 Validações: titulo presente, pergunta com pelo menos 2 opcoes_resposta e exatamente 1 correta
- [x] 5.7 Validação: nome é sempre obrigatório (regra implícita; coluna `nome` em `participacoes` será `null: false` na seção 9), email_state e phone_state com enum [not_asked, optional, required]

## 6. CRUD de Quiz

- [x] 6.1 Controller `Organizador::QuizzesController` (index/new/create/show/edit/update/destroy). Conflito de namespace `module Quiz` (app) vs `class Quiz` (model) resolvido renomeando o módulo da aplicação Rails para `QuizApp` em `config/application.rb`
- [x] 6.2 Scope: organizador só vê quizzes próprios (via `current_organizador.quizzes` no `carregar_quiz`)
- [x] 6.3 Views: lista, formulário, página `show` com seções placeholder para perguntas e campos personalizados (a serem preenchidas nas seções 7 e 8)
- [x] 6.4 Confirmação dupla na exclusão quando há campanhas com participações (helper `confirmacao_dupla_necessaria?` já posto; ativa quando os models de Campanha/Participacao existirem na seção 9)
- [x] 6.5 Banner de aviso quando email e telefone não são `required` (no `show`, via `quiz.identificadores_fracos?`)

## 7. CRUD de perguntas e opções

- [x] 7.1 Controller `Organizador::PerguntasController` nested em `:quizzes` (rotas `except: %i[index show]`, exclusão via `show` do quiz)
- [x] 7.2 Adicionar/editar/remover perguntas com `accepts_nested_attributes_for :opcoes_resposta` (incluindo `_destroy`)
- [x] 7.3 Reordenação por campo `posicao` (input numérico no form; ordenação pela default scope `order(:posicao, :id)` na associação)
- [x] 7.4 Validações herdadas do model (`ao_menos_duas_opcoes`, `exatamente_uma_correta`); form re-renderiza erros e garante ≥2 opções vazias após erro

## 8. CRUD de campos personalizados do participante

- [x] 8.1 Controller `Organizador::CamposPersonalizadosController` nested em quiz
- [x] 8.2 Form com rotulo, tipo (`CampoPersonalizado::TIPOS`), obrigatório e textarea de opções (uma por linha) parseado para JSON quando tipo == select
- [x] 8.3 Reordenação por campo `posicao` (input numérico no form)
- [x] 8.4 Edição e remoção via show do quiz

## 9. Modelo de dados — Campanha e participação

- [x] 9.1 Model `Campanha` (status enum draft/active/closed; scope `ativas`)
- [x] 9.2 Geração automática de slug a partir de `nome.parameterize`, com fallback `SecureRandom.hex(2)` em colisão
- [x] 9.3 Model `Participacao` com `before_validation` para normalizar email/telefone e gerar `token_participante`
- [x] 9.4 Model `Resposta` (uniqueness scoped por participacao_id/pergunta_id)
- [x] 9.5 Model `ValorCampoPersonalizado`
- [x] 9.6 Migrations + foreign keys + índices ((campanha_id,email), (campanha_id,telefone), unique (campanha_id,token_participante))
- [x] 9.7 `NormalizadorTelefone` em `app/services/normalizador_telefone.rb` (apenas dígitos), usado no `before_validation` da participação

## 10. CRUD de Campanha

- [x] 10.1 Controller `Organizador::CampanhasController` nested em quiz
- [x] 10.2 Form com nome, slug opcional, inicio_em/fim_em opcionais
- [x] 10.3 Unicidade de slug validada no model + format check com mensagem clara
- [x] 10.4 Edição de slug bloqueada quando `tem_participacoes?` (controller remove `:slug` dos params + form mostra disabled)
- [x] 10.5 Ações `ativar`/`encerrar` (rotas POST member, métodos no model)
- [x] 10.6 Banner de fragilidade no `new` e no `show` da campanha quando `quiz.identificadores_fracos?`

## 11. QR code e URL pública

- [x] 11.1 Service `GeradorQrCode` (`as_svg`/`as_png` via gem `rqrcode`)
- [x] 11.2 QR é gerado on-the-fly por request (sem cache no MVP — geração é barata e não-bloqueante; cache fica para próximo módulo se virar gargalo)
- [x] 11.3 Página `/organizador/quizzes/:quiz_id/campanhas/:campanha_id/qr_code` com SVG inline e URL legível
- [x] 11.4 Download via `format: :png` (`disposition: attachment`)
- [x] 11.5 Rota pública `GET /c/:slug` apontando para `Publico::CampanhasController#show`

## 12. Tela do participante (minimalista)

- [x] 12.1 Layout `participante.html.erb` minimalista (já existia; sem JS, sem fontes web)
- [x] 12.2 Action `show` trata draft (`forbidden`), closed (`gone`), inexistente (`not_found`) e active
- [x] 12.3 Form de identificação renderiza nome + email/telefone conforme `email_state`/`phone_state` + `campos_personalizados` (text/email/phone/select)
- [x] 12.4 Action `iniciar_participacao` valida, cria `Participacao` e persiste valores personalizados
- [x] 12.5 Cookie encrypted `:token_participante_quiz`, httponly, samesite lax, expira em 1 ano
- [x] 12.6 Form de perguntas: **todas na mesma página** (decisão: 1 round-trip único minimiza pedidos em rede ruim, condizente com Decisão 10 do design)
- [x] 12.7 Action `enviar_respostas` persiste em transação, conta acertos, marca `vencedor` quando 100% correto
- [x] 12.8 Tela de resultado diferencia vencedor (instruções de retirar prêmio) e agradecimento simples

## 13. Bloqueio de duplicata em camadas

- [x] 13.1 Service `VerificadorParticipacaoDuplicada` em `app/services/`, verifica cookie → email (downcased) → telefone (normalizado)
- [x] 13.2 Integração no `iniciar_participacao` antes do `save`
- [x] 13.3 View `ja_participou.html.erb`
- [x] 13.4 ~~Smoke tests cobrindo cada camada~~ — **FORA DE ESCOPO**: decisão do projeto de não adotar testes unitários/integração. Validação do bloqueio anti-duplicata fica a cargo do smoke manual (16.4/16.6).

## 14. Visualização de resultados

- [x] 14.1 `Organizador::ParticipacoesController#index` lista todas as participações da campanha
- [x] 14.2 Action `vencedores` filtra `vencedor = true` e reusa a mesma view
- [x] 14.3 Colunas dinâmicas a partir de `@quiz.campos_personalizados` + `valores_por_campo` indexado
- [x] 14.4 Empty state diferenciado para "todas" vs "vencedores"

## 15. Export CSV

- [x] 15.1 Service `ExportadorCsvCampanha` chamado via `format.csv` no `show` da campanha
- [x] 15.2 `CSV.generate(headers: true)` com colunas exigidas + campos personalizados dinâmicos
- [x] 15.3 Filename `campanha-#{slug}-YYYYMMDD.csv` via `send_data`
- [x] 15.4 Header-only por padrão quando não há respostas (loop `each` não roda)

## 16. Polimento e validação manual

- [x] 16.1 Verificar peso da página do participante (Lighthouse / DevTools throttle 3G) — validado manualmente
- [x] 16.2 Testar fluxo completo num celular real conectado em rede ruim — validado manualmente
- [x] 16.3 Verificar fluxo de reset de senha em ambiente real — validado manualmente
- [x] 16.4 Smoke test ponta-a-ponta — validado manualmente
- [x] 16.5 Locale pt-BR de errors/activerecord adicionado em `config/locales/pt-BR.yml` (chaves `required`, `blank`, `taken`, `invalid`, etc) — corrige "Translation missing" em validações
- [x] 16.6 Validar comportamento em quiz sem identificadores obrigatórios — validado manualmente

## 17. Documentação mínima

- [x] 17.1 README com setup local, seed do admin, áreas da aplicação
- [x] 17.2 Seção destacada no README "Tela do participante: footprint mínimo" com lista do que não fazer
