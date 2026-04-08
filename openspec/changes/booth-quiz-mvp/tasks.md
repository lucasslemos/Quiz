## 1. Setup do projeto

- [ ] 1.1 Adicionar Tailwind CSS ao projeto Rails 8.1
- [ ] 1.2 Adicionar gem `rqrcode` ao Gemfile
- [ ] 1.3 Configurar locale pt-BR como padrão (config.i18n.default_locale = :"pt-BR")
- [ ] 1.4 Decidir e configurar banco de dados (SQLite ou Postgres) para dev e prod
- [ ] 1.5 Criar layouts base separados: `application.html.erb` (organizer), `admin.html.erb`, `participant.html.erb` (minimalista)

## 2. Modelo de dados — Organizador e Admin

- [ ] 2.1 Gerar model `Organizer` com campos: email (unique), password_digest, status (enum: pending/approved/rejected/suspended), timestamps
- [ ] 2.2 Gerar model `Admin` com campos: email (unique), password_digest, timestamps
- [ ] 2.3 Migrations + índices únicos em email
- [ ] 2.4 Validações de modelo (email formato, senha mínimo 8 chars)
- [ ] 2.5 Seed de pelo menos um Admin inicial via `db/seeds.rb` ou rake task

## 3. Autenticação do organizador

- [ ] 3.1 Usar gerador de auth do Rails 8.1 (`bin/rails generate authentication`) adaptado ao model Organizer
- [ ] 3.2 Rotas: `/sign_up`, `/sign_in`, `/sign_out`, `/password/new`, `/password/edit`
- [ ] 3.3 Tela de "aguardando aprovação" exibida para organizadores `pending`
- [ ] 3.4 Concern `RequireApprovedOrganizer` que bloqueia rotas protegidas
- [ ] 3.5 Mensagens claras para `rejected` e `suspended` no login
- [ ] 3.6 Fluxo de recuperação de senha por email com token expirável (configurar mailer)

## 4. Autenticação do admin e painel

- [ ] 4.1 Sessão de admin separada (controllers em namespace `Admin::`)
- [ ] 4.2 Rotas `/admin/login`, `/admin/logout`
- [ ] 4.3 Concern `RequireAdmin` para proteger rotas `/admin/*`
- [ ] 4.4 Página `/admin/organizers` com filtro por status
- [ ] 4.5 Página `/admin/organizers/pending` com fila e ações aprovar/rejeitar
- [ ] 4.6 Ações `approve` e `reject` mudando o status do Organizer

## 5. Modelo de dados — Quiz e perguntas

- [ ] 5.1 Model `Quiz` (organizer_id, title, identifier configs como colunas: email_state, phone_state)
- [ ] 5.2 Model `Question` (quiz_id, text, position)
- [ ] 5.3 Model `AnswerOption` (question_id, text, correct boolean, position)
- [ ] 5.4 Model `ParticipantCustomField` (quiz_id, label, field_type enum, required, options JSON, position)
- [ ] 5.5 Migrations + foreign keys + índices
- [ ] 5.6 Validações: title presente, question pelo menos 2 options com exatamente 1 correct
- [ ] 5.7 Validação: name é sempre required (regra implícita), email_state e phone_state com enum [not_asked, optional, required]

## 6. CRUD de Quiz

- [ ] 6.1 Controller `Organizer::QuizzesController` (index/new/create/show/edit/update/destroy)
- [ ] 6.2 Scope: organizer só vê quizzes próprios
- [ ] 6.3 Views: lista, formulário, página de edição com aba/seção para perguntas e campos
- [ ] 6.4 Confirmação dupla na exclusão quando há campanhas com respostas
- [ ] 6.5 Banner de aviso quando email e phone não são `required` (fragilidade do anti-duplicata)

## 7. CRUD de perguntas e opções

- [ ] 7.1 Controller `Organizer::QuestionsController` (nested em quiz)
- [ ] 7.2 Adicionar/editar/remover perguntas com formulário aceitando opções inline (nested attributes)
- [ ] 7.3 Reordenação de perguntas (drag-and-drop simples ou campos de posição)
- [ ] 7.4 Validações no form: 2+ opções, exatamente 1 correta

## 8. CRUD de campos customizados do participante

- [ ] 8.1 Controller `Organizer::ParticipantCustomFieldsController` (nested em quiz)
- [ ] 8.2 Form para adicionar campo (label, tipo, required, options para select)
- [ ] 8.3 Reordenação de campos
- [ ] 8.4 Edição e remoção

## 9. Modelo de dados — Campanha e participação

- [ ] 9.1 Model `Campaign` (quiz_id, name, slug unique, status enum, starts_at, ends_at)
- [ ] 9.2 Geração automática de slug com fallback de hash em colisão
- [ ] 9.3 Model `Participation` (campaign_id, name, email, phone, participant_token, score, winner boolean, submitted_at)
- [ ] 9.4 Model `Response` (participation_id, question_id, answer_option_id)
- [ ] 9.5 Model `CustomFieldValue` (participation_id, participant_custom_field_id, value)
- [ ] 9.6 Migrations + índices em (campaign_id, email), (campaign_id, phone), (campaign_id, participant_token)
- [ ] 9.7 Normalização de telefone (helper) antes de salvar e comparar

## 10. CRUD de Campanha

- [ ] 10.1 Controller `Organizer::CampaignsController`
- [ ] 10.2 Form para criar campanha a partir de um quiz (name, slug opcional, datas opcionais)
- [ ] 10.3 Validação de unicidade de slug com mensagem clara
- [ ] 10.4 Bloquear edição de slug após primeira resposta
- [ ] 10.5 Ações `activate` e `close` mudando status
- [ ] 10.6 Banner de aviso sobre fragilidade quando aplicável

## 11. QR code e URL pública

- [ ] 11.1 Helper/serviço para gerar QR code via `rqrcode` (PNG e SVG)
- [ ] 11.2 Cache do QR code (Active Storage ou disco)
- [ ] 11.3 Página `/organizer/campaigns/:id/qr` mostrando QR + URL legível
- [ ] 11.4 Download do QR em tamanho imprimível
- [ ] 11.5 Rota pública `GET /c/:slug` apontando para `Public::CampaignsController`

## 12. Tela do participante (minimalista)

- [ ] 12.1 Layout `participant.html.erb` sem assets pesados, sem fontes web, sem Stimulus
- [ ] 12.2 Action `show` da campanha pública: trata estados draft/active/closed/inexistente
- [ ] 12.3 Form de identificação renderizando campos conforme config do quiz (nome + email/phone conforme estado + custom fields)
- [ ] 12.4 Action `start_participation` que valida campos e cria `Participation`
- [ ] 12.5 Geração e gravação de `participant_token` em cookie HttpOnly de longa duração
- [ ] 12.6 Form de perguntas (uma por uma ou todas na mesma página — escolher e documentar)
- [ ] 12.7 Action `submit_answers` que persiste `Response`s, calcula score, marca `winner` se acertou tudo
- [ ] 12.8 Tela de resultado: vencedor (instruções de retirar prêmio) ou agradecimento

## 13. Bloqueio de duplicata em camadas

- [ ] 13.1 Serviço `DuplicateParticipationChecker` que verifica em ordem: cookie token, email (case-insensitive), telefone (normalizado)
- [ ] 13.2 Integração no `start_participation`: bloquear antes de criar
- [ ] 13.3 Tela amigável de "você já participou desta campanha"
- [ ] 13.4 Testes cobrindo cada camada e o caso "tudo opcional + cookie limpo = passa"

## 14. Visualização de resultados

- [ ] 14.1 Página `/organizer/campaigns/:id/responses` listando todas as participações
- [ ] 14.2 Página `/organizer/campaigns/:id/winners` filtrando winner = true
- [ ] 14.3 Mostrar custom fields como colunas dinâmicas
- [ ] 14.4 Empty states em cada tela

## 15. Export CSV

- [ ] 15.1 Action `export.csv` no `Organizer::CampaignsController` ou serviço dedicado
- [ ] 15.2 Geração síncrona via `CSV.generate` com colunas: nome, email, telefone, custom fields, score, winner, submitted_at
- [ ] 15.3 Download com nome de arquivo derivado do slug da campanha
- [ ] 15.4 Header-only quando não há respostas

## 16. Polimento e validação manual

- [ ] 16.1 Verificar peso da página do participante (Lighthouse / DevTools throttle 3G)
- [ ] 16.2 Testar fluxo completo num celular real conectado em rede ruim
- [ ] 16.3 Verificar fluxo de reset de senha em ambiente real
- [ ] 16.4 Smoke test ponta-a-ponta: cadastro → aprovação → criar quiz → criar campanha → escanear QR → responder → ver resultado → exportar CSV
- [ ] 16.5 Mensagens de erro revisadas e amigáveis em pt-BR
- [ ] 16.6 Validar comportamento em quiz sem identificadores obrigatórios (banner aparece, cookie bloqueia, sem cookie passa)

## 17. Documentação mínima

- [ ] 17.1 README com instruções de setup local, seed do admin, e como rodar
- [ ] 17.2 Nota no README sobre o requisito de "tela leve do participante" e o que NÃO fazer ali
