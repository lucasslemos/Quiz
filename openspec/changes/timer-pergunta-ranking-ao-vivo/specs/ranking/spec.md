## ADDED Requirements

### Requirement: Cálculo de ranking por campanha
O sistema DEVE calcular o ranking dos participantes de uma campanha usando o critério: ordenação primária por número de acertos (decrescente), ordenação secundária por tempo total gasto (crescente — mais rápido primeiro). Apenas participações finalizadas (`enviado_em` preenchido) DEVEM aparecer no ranking.

#### Scenario: Ranking com acertos diferentes
- **WHEN** Maria acertou 5/5 em 42s e João acertou 4/5 em 30s
- **THEN** Maria aparece em 1º e João em 2º (acertos têm prioridade sobre tempo)

#### Scenario: Ranking com desempate por tempo
- **WHEN** Maria acertou 5/5 em 42s e João acertou 5/5 em 68s
- **THEN** Maria aparece em 1º e João em 2º (mesmo acertos, menor tempo vence)

#### Scenario: Participação não finalizada
- **WHEN** um participante abandonou o quiz antes de responder todas as perguntas
- **THEN** esse participante NÃO aparece no ranking

### Requirement: Ranking visível ao participante no resultado
Após finalizar o quiz, a tela de resultado DEVE exibir o ranking de todos os participantes da campanha (limitado aos 20 primeiros). A linha do participante atual DEVE ser destacada visualmente. A posição do participante DEVE ser informada em texto.

#### Scenario: Participante finaliza e vê ranking
- **WHEN** o participante finaliza o quiz e acessa a tela de resultado
- **THEN** o sistema exibe uma tabela com posição, nome, acertos e tempo total, com a linha do participante destacada

#### Scenario: Participante em posição fora do top 20
- **WHEN** o participante finaliza mas está na posição 25
- **THEN** o sistema exibe os 20 primeiros no ranking e informa a posição do participante (25º) separadamente

### Requirement: Ranking ao vivo para o organizador
O organizador DEVE ter acesso a uma tela de ranking ao vivo na área do organizador. Esta tela DEVE atualizar automaticamente via WebSocket (Turbo Streams) quando participantes finalizam o quiz, sem necessidade de refresh manual.

#### Scenario: Organizador abre ranking ao vivo
- **WHEN** o organizador acessa a tela de ranking ao vivo de uma campanha ativa
- **THEN** o sistema exibe uma tabela com posição, nome, acertos, tempo total e horário de conclusão, limitada a 50 participantes

#### Scenario: Novo participante finaliza o quiz
- **WHEN** um participante finaliza o quiz enquanto o organizador está com a tela de ranking ao vivo aberta
- **THEN** a tabela de ranking é atualizada automaticamente sem refresh, refletindo a nova classificação

#### Scenario: Organizador tenta acessar ranking de outro organizador
- **WHEN** um organizador tenta se inscrever no channel de ranking de uma campanha que não pertence a ele
- **THEN** o sistema rejeita a inscrição no WebSocket

### Requirement: Tempo total denormalizado na participação
A `Participacao` DEVE armazenar `tempo_total_ms` como soma de todos os `tempo_resposta_ms` das respostas. Este campo DEVE ser calculado na finalização e usado para ordenação do ranking sem necessidade de joins.

#### Scenario: Participação finalizada com tempos variados
- **WHEN** um participante responde 3 perguntas em 5000ms, 8000ms e 12000ms
- **THEN** `tempo_total_ms` é salvo como 25000
