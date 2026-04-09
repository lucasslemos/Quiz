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

- [ ] 5.1 Model `Quiz` (organizador_id, titulo, configs de identificador como colunas: email_state, phone_state) — manter `Quiz` em inglês (nome do app/domínio)
- [ ] 5.2 Model `Pergunta` (tabela `perguntas`) (quiz_id, texto, posicao)
- [ ] 5.3 Model `OpcaoResposta` (tabela `opcoes_resposta`) (pergunta_id, texto, correta boolean, posicao)
- [ ] 5.4 Model `CampoPersonalizado` (tabela `campos_personalizados`) (quiz_id, rotulo, tipo_campo enum, obrigatorio, opcoes JSON, posicao)
- [ ] 5.5 Migrations + foreign keys + índices
- [ ] 5.6 Validações: titulo presente, pergunta com pelo menos 2 opcoes_resposta e exatamente 1 correta
- [ ] 5.7 Validação: nome é sempre obrigatório (regra implícita), email_state e phone_state com enum [not_asked, optional, required]

## 6. CRUD de Quiz

- [ ] 6.1 Controller `Organizador::QuizzesController` (index/new/create/show/edit/update/destroy)
- [ ] 6.2 Scope: organizador só vê quizzes próprios
- [ ] 6.3 Views: lista, formulário, página de edição com aba/seção para perguntas e campos personalizados
- [ ] 6.4 Confirmação dupla na exclusão quando há campanhas com participações
- [ ] 6.5 Banner de aviso quando email e telefone não são `required` (fragilidade do anti-duplicata)

## 7. CRUD de perguntas e opções

- [ ] 7.1 Controller `Organizador::PerguntasController` (nested em quiz)
- [ ] 7.2 Adicionar/editar/remover perguntas com formulário aceitando opções inline (nested attributes)
- [ ] 7.3 Reordenação de perguntas (drag-and-drop simples ou campos de posição)
- [ ] 7.4 Validações no form: 2+ opcoes_resposta, exatamente 1 correta

## 8. CRUD de campos personalizados do participante

- [ ] 8.1 Controller `Organizador::CamposPersonalizadosController` (nested em quiz)
- [ ] 8.2 Form para adicionar campo (rotulo, tipo, obrigatorio, opcoes para select)
- [ ] 8.3 Reordenação de campos
- [ ] 8.4 Edição e remoção

## 9. Modelo de dados — Campanha e participação

- [ ] 9.1 Model `Campanha` (tabela `campanhas`) (quiz_id, nome, slug unique, status enum, inicio_em, fim_em)
- [ ] 9.2 Geração automática de slug com fallback de hash em colisão
- [ ] 9.3 Model `Participacao` (tabela `participacoes`) (campanha_id, nome, email, telefone, token_participante, pontuacao, vencedor boolean, enviado_em)
- [ ] 9.4 Model `Resposta` (tabela `respostas`) (participacao_id, pergunta_id, opcao_resposta_id)
- [ ] 9.5 Model `ValorCampoPersonalizado` (tabela `valores_campo_personalizado`) (participacao_id, campo_personalizado_id, valor)
- [ ] 9.6 Migrations + índices em (campanha_id, email), (campanha_id, telefone), (campanha_id, token_participante)
- [ ] 9.7 Normalização de telefone (helper) antes de salvar e comparar

## 10. CRUD de Campanha

- [ ] 10.1 Controller `Organizador::CampanhasController`
- [ ] 10.2 Form para criar campanha a partir de um quiz (nome, slug opcional, datas opcionais)
- [ ] 10.3 Validação de unicidade de slug com mensagem clara
- [ ] 10.4 Bloquear edição de slug após primeira participação
- [ ] 10.5 Ações `ativar` e `encerrar` mudando status
- [ ] 10.6 Banner de aviso sobre fragilidade quando aplicável

## 11. QR code e URL pública

- [ ] 11.1 Service `GeradorQrCode` para gerar QR code via `rqrcode` (PNG e SVG)
- [ ] 11.2 Cache do QR code (Active Storage ou disco)
- [ ] 11.3 Página `/organizador/campanhas/:id/qr` mostrando QR + URL legível
- [ ] 11.4 Download do QR em tamanho imprimível
- [ ] 11.5 Rota pública `GET /c/:slug` apontando para `Publico::CampanhasController`

## 12. Tela do participante (minimalista)

- [ ] 12.1 Layout `participante.html.erb` sem assets pesados, sem fontes web, sem Stimulus
- [ ] 12.2 Action `show` da campanha pública: trata estados draft/active/closed/inexistente
- [ ] 12.3 Form de identificação renderizando campos conforme config do quiz (nome + email/telefone conforme estado + campos personalizados)
- [ ] 12.4 Action `iniciar_participacao` que valida campos e cria `Participacao`
- [ ] 12.5 Geração e gravação de `token_participante` em cookie HttpOnly de longa duração
- [ ] 12.6 Form de perguntas (uma por uma ou todas na mesma página — escolher e documentar)
- [ ] 12.7 Action `enviar_respostas` que persiste `Resposta`s, calcula pontuação, marca `vencedor` se acertou tudo
- [ ] 12.8 Tela de resultado: vencedor (instruções de retirar prêmio) ou agradecimento

## 13. Bloqueio de duplicata em camadas

- [ ] 13.1 Service `VerificadorParticipacaoDuplicada` que verifica em ordem: cookie token, email (case-insensitive), telefone (normalizado)
- [ ] 13.2 Integração no `iniciar_participacao`: bloquear antes de criar
- [ ] 13.3 Tela amigável de "você já participou desta campanha"
- [ ] 13.4 Smoke tests cobrindo cada camada e o caso "tudo opcional + cookie limpo = passa"

## 14. Visualização de resultados

- [ ] 14.1 Página `/organizador/campanhas/:id/participacoes` listando todas as participações
- [ ] 14.2 Página `/organizador/campanhas/:id/vencedores` filtrando vencedor = true
- [ ] 14.3 Mostrar campos personalizados como colunas dinâmicas
- [ ] 14.4 Empty states em cada tela

## 15. Export CSV

- [ ] 15.1 Action `exportar.csv` no `Organizador::CampanhasController` ou service dedicado `ExportadorCsvCampanha`
- [ ] 15.2 Geração síncrona via `CSV.generate` com colunas: nome, email, telefone, campos personalizados, pontuacao, vencedor, enviado_em
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

- [ ] 17.1 README com instruções de setup local, seed do administrador, e como rodar
- [ ] 17.2 Nota no README sobre o requisito de "tela leve do participante" e o que NÃO fazer ali
