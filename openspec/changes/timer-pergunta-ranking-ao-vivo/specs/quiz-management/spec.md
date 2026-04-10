## MODIFIED Requirements

### Requirement: Create quiz
Um organizador aprovado DEVE poder criar um novo quiz informando no mínimo um título. O quiz DEVE ser criado com `tempo_por_pergunta` padrão de 30 segundos.

#### Scenario: Criando quiz com título válido
- **WHEN** um organizador aprovado submete o formulário de novo quiz com título não vazio
- **THEN** o sistema cria o quiz com configuração padrão de identificadores (nome obrigatório, email e telefone não pedidos), zero perguntas e `tempo_por_pergunta: 30`

#### Scenario: Criando quiz com título vazio
- **WHEN** um organizador submete o formulário com título vazio
- **THEN** o sistema rejeita com erro de validação

### Requirement: Edit quiz
Um organizador DEVE poder editar o título, configuração de identificadores e `tempo_por_pergunta` de um quiz que ele possua. O campo `tempo_por_pergunta` DEVE aceitar valores entre 5 e 300 segundos.

#### Scenario: Atualizando tempo por pergunta
- **WHEN** um organizador altera `tempo_por_pergunta` para 15 e salva
- **THEN** o sistema persiste o novo valor e campanhas futuras usam esse tempo

#### Scenario: Tempo por pergunta inválido
- **WHEN** um organizador tenta salvar `tempo_por_pergunta` como 2 (abaixo do mínimo)
- **THEN** o sistema rejeita com erro de validação

#### Scenario: Editando quiz de outro organizador
- **WHEN** um organizador tenta editar um quiz que não é dele
- **THEN** o sistema nega a ação com resposta not-found ou forbidden
