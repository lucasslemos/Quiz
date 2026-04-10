## Context

O quiz atual funciona como um formulário estático: todas as perguntas são exibidas de uma vez, o participante responde no seu ritmo e submete tudo junto. Não há limite de tempo, medição de velocidade nem comparação entre participantes.

O projeto já possui a infraestrutura necessária para as mudanças:
- **Stimulus** e **Turbo** estão configurados no bundle JS (esbuild), porém o layout `participante.html.erb` não carrega o JS bundle — só o CSS.
- **Solid Cable** está configurado em `config/cable.yml`, mas nenhum channel ActionCable existe ainda.
- O model `Resposta` registra apenas qual opção foi escolhida, sem timestamp de resposta nem duração.
- O model `Participacao` tem `pontuacao` (contagem de acertos) e `vencedor` (bool), mas sem dado de tempo.

## Goals / Non-Goals

**Goals:**
- Permitir que o organizador configure um tempo limite por pergunta no quiz
- Exibir perguntas uma por vez com countdown visual e auto-submissão no timeout
- Registrar o tempo de resposta de cada pergunta
- Exibir ranking de participantes ao final do quiz (critério: acertos desc, tempo asc)
- Fornecer tela de ranking ao vivo para o organizador via Turbo Streams

**Non-Goals:**
- Timer individual por pergunta (tempo diferente para cada questão)
- Pontuação ponderada por velocidade (estilo Kahoot)
- Ranking público sem autenticação (telão aberto para audiência)
- Modo offline ou Progressive Web App

## Decisions

### 1. Fluxo pergunta-a-pergunta via server-side dispatch

**Decisão:** Cada pergunta é uma rota GET individual (`/c/:slug/pergunta/:numero`). A submissão é um POST individual. Um dispatcher GET `/c/:slug/responder` calcula qual é a próxima pergunta não respondida e redireciona.

**Alternativa considerada:** Single-page com Stimulus controlando tudo no client, sem round-trips. Descartada porque (a) aumenta complexidade do JS significativamente, (b) dificulta validação server-side, (c) permite manipulação do client (pular timer, ver respostas no DOM).

**Justificativa:** O round-trip com Turbo é rápido o suficiente (Turbo intercepta links/forms e faz fetch), mantém a lógica no server, e cada resposta é persistida imediatamente — se o participante fechar o browser, o progresso é preservado.

### 2. Timer implementado via Stimulus controller

**Decisão:** Um Stimulus controller `cronometro` gerencia o countdown no client. O server embute `Time.current.to_f` no HTML como `data-value`. O controller calcula o tempo já decorrido (latência de rede/render) e desconta do budget.

**Justificativa:** O timer precisa ser visual e fluido — isso só funciona no client. O timestamp do server permite compensar latência. O server faz clamp do `tempo_ms` recebido para evitar trapaça (`0..limite+2s`).

### 3. Timeout registrado como Resposta com `opcao_resposta_id: null`

**Decisão:** Quando o tempo esgota sem seleção, o form é auto-submetido sem `opcao_resposta_id`. O server cria uma `Resposta` com `opcao_resposta_id: null` e `tempo_resposta_ms` igual ao limite.

**Alternativa considerada:** Não criar registro de resposta e tratar a ausência como "não respondida". Descartada porque o dispatcher precisa saber quais perguntas já foram apresentadas — sem registro, o participante veria a mesma pergunta novamente.

**Justificativa:** O unique index `(participacao_id, pergunta_id)` continua funcionando. O método `correta?` retorna `false` para `nil`. A coluna `opcao_resposta_id` precisa virar nullable na migration.

### 4. Ranking com critério simples: acertos > tempo

**Decisão:** `ORDER BY pontuacao DESC, tempo_total_ms ASC`. Denormalizar `tempo_total_ms` na tabela `participacoes` para evitar joins no ranking.

**Alternativa considerada:** Pontuação ponderada (acerto rápido = mais pontos). Descartada por adicionar complexidade e reduzir transparência — o participante não entenderia facilmente como a pontuação é calculada.

### 5. Ranking ao vivo via Turbo Streams broadcast

**Decisão:** Usar `Turbo::StreamsChannel.broadcast_replace_to` disparado por `after_commit` no model `Participacao` quando `enviado_em` muda. O partial `_tabela_ranking` é re-renderizado e enviado ao organizer via WebSocket (Solid Cable).

**Alternativa considerada:** Polling com meta refresh ou Stimulus timer. Descartada porque Solid Cable já está configurado e Turbo Streams broadcast é nativo do Rails 8.1 — não há razão para usar polling.

**Justificativa:** O channel `RankingCampanhaChannel` autoriza apenas o organizador dono do quiz. A view do organizador usa `turbo_stream_from` para se inscrever.

### 6. Layout participante precisa carregar JS

**Decisão:** Adicionar `javascript_include_tag "application"` ao layout `participante.html.erb`.

**Trade-off:** Isso carrega o bundle JS completo (Turbo + Stimulus + Bootstrap JS) para o participante, quando antes era zero JS. Porém, o bundle já é cacheado pelo browser (mesmo domínio), e sem JS o cronômetro não funciona.

### 7. Service `CalculadoraPontuacao` para finalização

**Decisão:** Extrair a lógica de cálculo de pontuação para um service object `CalculadoraPontuacao.call(participacao)`, que contabiliza acertos, soma tempos e atualiza a participação.

**Justificativa:** O controller ficaria grande demais com essa lógica inline. O service permite reusar a lógica se necessário (ex: recalcular pontuação em caso de correção).

## Risks / Trade-offs

**[Latência entre perguntas]** → Turbo faz fetch via XHR e renderiza parcial, mantendo a transição rápida (~100-200ms em rede local). Para eventos com internet ruim, o timer do server (`@iniciado_em`) compensa o tempo de carregamento automaticamente.

**[Manipulação do timer no client]** → O server faz clamp do `tempo_ms` recebido em `0..(limite+2)*1000`. Um participante pode enviar `tempo_ms: 0` (fingir resposta instantânea), mas isso é aceitável — a resposta ainda precisa ser correta para pontuar. Fraude mais sofisticada (inspecionar DOM para ver resposta correta) já é possível hoje e está fora do escopo.

**[Broadcast para muitos organizadores]** → Na prática, apenas 1 organizador assiste o ranking por campanha. Se múltiplos organizadores assistirem, o broadcast é o mesmo payload via pub/sub — sem impacto.

**[Migration com nullable]** → `change_column_null :respostas, :opcao_resposta_id, true` é uma operação segura em MySQL (ALTER TABLE, mas sem reescrita de dados pois só muda o constraint). A FK para `opcoes_resposta` precisa permitir null — o `belongs_to :opcao_resposta, optional: true` cuida disso no Rails.

**[JS bundle no layout participante]** → Aumenta o payload inicial para participantes. Mitigação: o bundle é cacheado, e Propshaft faz fingerprinting. Em redes muito lentas, o timer pode iniciar com atraso — mas o timestamp do server compensa isso automaticamente.
