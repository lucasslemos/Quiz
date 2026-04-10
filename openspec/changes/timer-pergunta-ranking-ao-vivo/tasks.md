## 1. Migrations e schema

- [x] 1.1 Criar migration `AddTempoPerPerguntaToQuizzes` — coluna `tempo_por_pergunta :integer, null: false, default: 30` na tabela `quizzes`
- [x] 1.2 Criar migration `AddTimingToRespostas` — coluna `tempo_resposta_ms :integer` e `change_column_null :opcao_resposta_id, true` na tabela `respostas`
- [x] 1.3 Criar migration `AddTempoTotalMsToParticipacoes` — coluna `tempo_total_ms :integer, null: false, default: 0` na tabela `participacoes`
- [x] 1.4 Executar `rails db:migrate` e verificar `db/schema.rb`

## 2. Models

- [x] 2.1 Atualizar `Quiz` — adicionar validação de `tempo_por_pergunta` (inteiro, entre 5 e 300)
- [x] 2.2 Atualizar `Resposta` — tornar `belongs_to :opcao_resposta` optional, ajustar `correta?` para nil-safe
- [x] 2.3 Atualizar `Participacao` — adicionar scope `ranking`, método `finalizada?` e callback `after_commit :transmitir_ranking` (callback fica inativo até o channel existir na task 5.2)
- [x] 2.4 Atualizar `Campanha` — adicionar método `ranking` delegando para `participacoes.ranking`

## 3. Service de pontuação

- [x] 3.1 Criar `app/services/calculadora_pontuacao.rb` — contabiliza acertos, soma tempos, atualiza `pontuacao`, `tempo_total_ms`, `vencedor` e `enviado_em`

## 4. Rotas

- [x] 4.1 Adicionar rotas públicas para pergunta individual: GET e POST `/c/:slug/pergunta/:numero`
- [x] 4.2 Remover rota `publico_campanha_enviar` (POST `/c/:slug/responder`)
- [x] 4.3 Adicionar rota `ranking_ao_vivo` na collection de `participacoes` do organizador

## 5. ActionCable

- [ ] 5.1 Criar `app/channels/application_cable/connection.rb` — identificar `current_organizador` via session (`session[:organizador_id]`)
- [ ] 5.2 Criar `app/channels/ranking_campanha_channel.rb` — autorizar organizador, stream para `ranking_campanha_<id>`, método de classe `transmitir_para(campanha)` usando `Turbo::StreamsChannel.broadcast_replace_to`

## 6. Stimulus controller

- [ ] 6.1 Criar `app/javascript/controllers/cronometro_controller.js` — countdown visual, auto-submissão no timeout, registro de tempo na seleção
- [ ] 6.2 Registrar controller em `app/javascript/controllers/index.js`

## 7. Controller público (fluxo pergunta-a-pergunta)

- [ ] 7.1 Reescrever action `responder` como dispatcher — calcula próxima pergunta, redireciona ou finaliza
- [ ] 7.2 Criar action `pergunta` (GET) — exibe pergunta individual com dados do timer
- [ ] 7.3 Criar action `responder_pergunta` (POST) — registra resposta com tempo, valida clamp server-side
- [ ] 7.4 Atualizar action `resultado` — carregar ranking da campanha e posição do participante
- [ ] 7.5 Remover action `enviar_respostas`

## 8. Controller do organizador

- [ ] 8.1 Adicionar `:tempo_por_pergunta` ao `quiz_params` em `Organizador::QuizzesController`
- [ ] 8.2 Criar action `ranking_ao_vivo` em `Organizador::ParticipacoesController`

## 9. Views

- [ ] 9.1 Criar `app/views/publico/campanhas/pergunta.html.erb` — pergunta individual com cronômetro Stimulus, barra de progresso e form
- [ ] 9.2 Atualizar `app/views/publico/campanhas/resultado.html.erb` — exibir pontuação, tempo total e tabela de ranking com destaque do participante
- [ ] 9.3 Criar `app/views/organizador/participacoes/ranking_ao_vivo.html.erb` — tela com `turbo_stream_from` e tabela de ranking
- [ ] 9.4 Criar `app/views/organizador/participacoes/_tabela_ranking.html.erb` — partial da tabela de ranking reutilizável
- [ ] 9.5 Atualizar `app/views/organizador/campanhas/show.html.erb` — adicionar botão "Ranking ao vivo"
- [ ] 9.6 Atualizar `app/views/organizador/quizzes/_form.html.erb` — adicionar campo `tempo_por_pergunta`

## 10. Layout e assets

- [ ] 10.1 Atualizar `app/views/layouts/participante.html.erb` — adicionar `javascript_include_tag "application"` para habilitar Stimulus/Turbo
- [ ] 10.2 Executar `yarn build` e verificar que o bundle inclui o cronômetro controller

## 11. Verificação manual end-to-end

- [ ] 11.1 Criar quiz com `tempo_por_pergunta: 15` e 3 perguntas, ativar campanha
- [ ] 11.2 Testar fluxo completo: registro, perguntas uma por vez com countdown, timeout, resultado com ranking
- [ ] 11.3 Testar ranking ao vivo do organizador: abrir tela, completar quiz em outra aba, verificar atualização automática
- [ ] 11.4 Testar retomada: fechar browser durante quiz, reabrir, verificar que continua da pergunta pendente
