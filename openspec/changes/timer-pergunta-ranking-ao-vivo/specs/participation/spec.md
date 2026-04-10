## MODIFIED Requirements

### Requirement: Question flow
Após submeter o formulário de identificação, o participante DEVE ser direcionado ao dispatcher (`/c/:slug/responder`) que o encaminha para a primeira pergunta. As perguntas DEVEM ser exibidas uma por vez, cada uma com countdown visual. O participante DEVE selecionar uma opção e confirmar, ou aguardar o timeout (auto-submissão). Cada resposta é registrada individualmente com o tempo gasto. Após a última pergunta, o dispatcher finaliza a participação e redireciona ao resultado.

#### Scenario: Participante responde todas as perguntas
- **WHEN** o participante responde cada pergunta dentro do tempo limite
- **THEN** o sistema registra cada resposta com `opcao_resposta_id` e `tempo_resposta_ms`, e ao final calcula pontuação, tempo total e redireciona ao resultado

#### Scenario: Participante deixa uma pergunta expirar
- **WHEN** o countdown de uma pergunta chega a zero sem seleção
- **THEN** o sistema registra a resposta com `opcao_resposta_id: null` (conta como errada) e avança para a próxima pergunta

#### Scenario: Participante fecha o browser e retorna
- **WHEN** o participante fecha o browser durante o quiz e retorna via `/c/:slug`
- **THEN** o sistema detecta o cookie, identifica quais perguntas já foram respondidas, e encaminha para a próxima pergunta pendente

### Requirement: Result screen and winner determination
Após responder todas as perguntas, o participante DEVE ver uma tela de resultado com: indicação de acertos, tempo total gasto e ranking da campanha. A participação DEVE ser marcada como vencedora se e somente se todas as respostas forem corretas.

#### Scenario: Participante acerta tudo
- **WHEN** o participante finaliza com todas as respostas corretas
- **THEN** o sistema marca como vencedor, exibe parabéns com pontuação, tempo total e posição no ranking

#### Scenario: Participante erra ao menos uma
- **WHEN** o participante finaliza com ao menos uma resposta errada ou timeout
- **THEN** o sistema exibe agradecimento com pontuação, tempo total e posição no ranking
