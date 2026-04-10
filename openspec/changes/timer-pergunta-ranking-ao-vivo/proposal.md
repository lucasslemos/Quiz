## Why

O quiz atual exibe todas as perguntas de uma vez, sem limite de tempo e sem ranking entre participantes. Isso gera uma experiência estática — o participante responde no seu ritmo, sem tensão ou competitividade. O organizador quer transformar o quiz em algo mais dinâmico, estilo "game show", onde cada pergunta tem um countdown e, ao final, os participantes competem por posição num ranking visível. O organizador precisa acompanhar esse ranking em tempo real durante o evento.

## What Changes

- **Configuração de tempo por pergunta**: o organizador define `tempo_por_pergunta` (em segundos) ao criar/editar o quiz. Cada pergunta usa esse mesmo limite.
- **Fluxo pergunta-a-pergunta**: as perguntas passam a ser exibidas uma por vez (em vez de todas num formulário único), com countdown visual e auto-submissão quando o tempo esgota.
- **Registro de tempo por resposta**: cada `Resposta` armazena o tempo gasto pelo participante (em milissegundos). Respostas por timeout ficam sem opção selecionada (null).
- **Ranking para participantes**: ao finalizar o quiz, o participante vê um ranking de todos os participantes da campanha. Critério: mais acertos primeiro, menor tempo total como desempate.
- **Ranking ao vivo para o organizador**: tela dedicada no painel do organizador que atualiza automaticamente via ActionCable/Turbo Streams quando participantes finalizam o quiz.

## Não-objetivos

- Timer por pergunta individual (cada pergunta com tempo diferente) — o tempo é configurado por quiz, igual para todas as perguntas.
- Pontuação ponderada por velocidade (estilo Kahoot) — o ranking usa critério simples: acertos > tempo.
- Ranking público sem autenticação (telão aberto) — o ranking ao vivo é restrito ao organizador logado.
- Perguntas com imagem ou mídia — fora do escopo.
- Pausar/retomar quiz — uma vez iniciado, o participante vai até o fim.

## Capabilities

### New Capabilities
- `timer-pergunta`: Countdown visual por pergunta com auto-submissão no timeout, fluxo pergunta-a-pergunta e registro de tempo por resposta.
- `ranking`: Ranking de participantes por campanha (exibido ao participante no resultado e ao vivo para o organizador via ActionCable/Turbo Streams).

### Modified Capabilities
- `participation`: O fluxo de resposta muda de form único para pergunta-a-pergunta. A `Resposta` passa a permitir `opcao_resposta_id` nulo (timeout). A `Participacao` ganha `tempo_total_ms`.
- `quiz-management`: O `Quiz` ganha o campo `tempo_por_pergunta` configurável pelo organizador.

## Impact

- **Schema MySQL**: 3 migrations — nova coluna em `quizzes`, nova coluna + nullable em `respostas`, nova coluna em `participacoes`. Todas reversíveis.
- **Controller público**: reescrita significativa de `Publico::CampanhasController` (fluxo pergunta-a-pergunta, novo dispatcher, novas actions).
- **Rotas**: novas rotas públicas para pergunta individual; nova rota de ranking ao vivo no organizador.
- **Frontend**: novo Stimulus controller para cronômetro; layout `participante.html.erb` precisa carregar JS bundle.
- **ActionCable**: primeiro channel real do projeto (`RankingCampanhaChannel`); `ApplicationCable::Connection` precisa identificar o organizador.
- **Nenhuma gem nova** — tudo com recursos nativos do Rails 8.1 (Turbo Streams, Stimulus, ActionCable/Solid Cable).
