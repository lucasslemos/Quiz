## ADDED Requirements

### Requirement: Configuração de tempo por pergunta no quiz
O quiz DEVE possuir um campo `tempo_por_pergunta` (inteiro, em segundos) que define o limite de tempo para cada pergunta. O valor DEVE ser entre 5 e 300 segundos. O valor padrão DEVE ser 30 segundos.

#### Scenario: Organizador cria quiz com tempo padrão
- **WHEN** um organizador cria um quiz sem informar tempo por pergunta
- **THEN** o sistema define `tempo_por_pergunta` como 30 segundos

#### Scenario: Organizador configura tempo personalizado
- **WHEN** um organizador define `tempo_por_pergunta` como 15 no formulário do quiz
- **THEN** o sistema persiste o valor e todas as perguntas desse quiz usam 15 segundos como limite

#### Scenario: Organizador tenta definir tempo inválido
- **WHEN** um organizador tenta salvar `tempo_por_pergunta` como 0, negativo ou maior que 300
- **THEN** o sistema rejeita com erro de validação

### Requirement: Exibição de pergunta individual com countdown
O sistema DEVE exibir as perguntas uma por vez na rota `/c/:slug/pergunta/:numero`. Cada pergunta DEVE mostrar um countdown visual (texto + barra de progresso) com o tempo restante. O número da pergunta atual e o total DEVEM ser exibidos.

#### Scenario: Participante acessa a primeira pergunta
- **WHEN** um participante é redirecionado para `/c/:slug/pergunta/1`
- **THEN** o sistema exibe a primeira pergunta do quiz com countdown iniciando no valor de `tempo_por_pergunta` e indicação "Pergunta 1 de N"

#### Scenario: Participante acessa pergunta já respondida
- **WHEN** um participante tenta acessar diretamente uma pergunta que já respondeu
- **THEN** o sistema redireciona para o dispatcher que encaminha à próxima pergunta não respondida

#### Scenario: Participante acessa número de pergunta inexistente
- **WHEN** um participante acessa `/c/:slug/pergunta/99` e o quiz tem apenas 5 perguntas
- **THEN** o sistema redireciona para o dispatcher

### Requirement: Auto-submissão no timeout
Quando o countdown chega a zero sem o participante selecionar uma opção, o sistema DEVE auto-submeter o formulário sem opção selecionada. A resposta DEVE ser registrada com `opcao_resposta_id` nulo e `tempo_resposta_ms` igual ao limite em milissegundos.

#### Scenario: Tempo esgota sem seleção
- **WHEN** o countdown de uma pergunta chega a zero e o participante não selecionou nenhuma opção
- **THEN** o formulário é submetido automaticamente, uma `Resposta` é criada com `opcao_resposta_id: null` e `tempo_resposta_ms` igual a `tempo_por_pergunta * 1000`, e o participante é redirecionado à próxima pergunta

#### Scenario: Tempo esgota após seleção sem confirmar
- **WHEN** o participante seleciona uma opção mas não clica em confirmar antes do tempo esgotar
- **THEN** o formulário é submetido automaticamente com a opção selecionada e o tempo registrado como o limite

### Requirement: Registro de tempo por resposta
Cada `Resposta` DEVE registrar o tempo gasto pelo participante em milissegundos no campo `tempo_resposta_ms`. O tempo é medido do carregamento da pergunta até a seleção da opção (ou timeout).

#### Scenario: Participante responde em 5 segundos
- **WHEN** o participante seleciona uma opção 5 segundos após a pergunta ser exibida e confirma
- **THEN** a `Resposta` é criada com `tempo_resposta_ms` aproximadamente igual a 5000

#### Scenario: Server valida tempo recebido
- **WHEN** o client envia `tempo_ms` maior que `(tempo_por_pergunta + 2) * 1000`
- **THEN** o server faz clamp do valor ao limite máximo permitido

### Requirement: Dispatcher de perguntas
A rota GET `/c/:slug/responder` DEVE funcionar como dispatcher: calcular qual é a próxima pergunta não respondida e redirecionar. Se todas as perguntas foram respondidas, DEVE finalizar a participação (calcular pontuação e tempo total) e redirecionar para o resultado.

#### Scenario: Participante com perguntas pendentes
- **WHEN** o participante acessa o dispatcher e ainda tem perguntas não respondidas
- **THEN** o sistema redireciona para a rota da próxima pergunta (menor posição não respondida)

#### Scenario: Todas as perguntas respondidas
- **WHEN** o participante acessa o dispatcher e já respondeu todas as perguntas
- **THEN** o sistema calcula a pontuação final e o tempo total, marca `enviado_em`, e redireciona para `/c/:slug/resultado`

#### Scenario: Participante já finalizado acessa o dispatcher
- **WHEN** o participante com `enviado_em` preenchido acessa o dispatcher
- **THEN** o sistema redireciona diretamente para o resultado sem recalcular
