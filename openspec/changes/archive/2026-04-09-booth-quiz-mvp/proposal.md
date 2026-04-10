## Why

Organizadores de eventos (estandes corporativos, ativações de marca) precisam de uma forma simples de engajar o público com quizzes gamificados que recompensam quem acerta tudo, mas as ferramentas existentes ou são caras, ou exigem login do participante, ou misturam funcionalidades demais. Este MVP entrega o caminho mais curto entre "organizador quer rodar um quiz no estande" e "tem a lista de ganhadores na mão pra entregar prêmio" — sem fricção pro participante (sem conta, sem login) e sem dependência do dono da plataforma pra operar.

## What Changes

- Cadastro livre de organizadores com aprovação manual via painel `/admin` antes de poder criar quizzes
- Autenticação de organizador (login, logout, recuperação de senha) usando o gerador nativo do Rails 8.1
- Painel administrativo (`/admin`) restrito ao dono da plataforma, com fila de organizadores pendentes e ação de aprovar/rejeitar
- CRUD de quiz pelo organizador, contendo perguntas com texto, alternativas e indicação da resposta correta
- Configuração de campos do participante por quiz: três campos especiais fixos (nome sempre obrigatório; email e telefone com estados "não pedir / opcional / obrigatório") mais campos extras customizados pelo organizador (estrutura de dados modelada desde já, mesmo que UI inicial entregue só os três fixos)
- Aviso visível ao organizador quando todos os identificadores são opcionais, explicando a fragilidade do bloqueio anti-duplicata
- Conceito de Campanha: instância de execução de um Quiz (ex: "AWS Summit 2026"), permitindo reusar o mesmo quiz em vários eventos com resultados separados
- Geração de QR code por Campanha, com download em tamanho imprimível e URL curta legível como backup
- Tela pública do participante (sem autenticação): escaneia QR → preenche campos configurados → responde → vê resultado. Otimizada para wifi saturado / 4G ruim de evento (HTML/CSS/JS mínimos)
- Bloqueio de resposta única por Campanha: cookie de navegador sempre, mais bloqueio por email/telefone quando esses dados foram preenchidos pelo participante
- Visualização das respostas de uma Campanha pelo organizador, incluindo lista filtrada de ganhadores (quem acertou todas as perguntas)
- Exportação CSV das respostas de uma Campanha, para que o organizador entregue prêmios offline ou rode sorteios externos

## Capabilities

### New Capabilities
- `organizer-auth`: cadastro, login, logout e recuperação de senha do organizador, com estado de aprovação que controla acesso à criação de quizzes
- `admin-approval`: painel administrativo restrito ao dono da plataforma para aprovar/rejeitar organizadores pendentes
- `quiz-management`: CRUD de quizzes e perguntas pelo organizador, incluindo configuração dos campos do participante (3 fixos + extras customizáveis)
- `campaign`: criação e gestão de Campanhas (instâncias de execução de um Quiz), geração de QR code e URL curta de backup
- `participation`: tela pública do participante, validação dos campos configurados, registro de respostas, regra de "uma vez por campanha" via cookie + email/telefone, e cálculo de ganhadores (acertou tudo)
- `results-export`: visualização das respostas e ganhadores por campanha pelo organizador, com exportação CSV

### Modified Capabilities
<!-- Nenhuma — projeto novo, não há specs prévias -->

## Impact

- **Código**: projeto Rails 8.1 ainda praticamente vazio; este MVP define toda a estrutura inicial de models, controllers, views e rotas
- **Dependências novas**: gem para geração de QR code (ex: `rqrcode`); gerador de auth nativo do Rails 8.1; possivelmente gem para slugs/URLs curtas
- **Banco de dados**: novas tabelas para `organizers`, `quizzes`, `questions`, `answer_options`, `participant_field_configs`, `campaigns`, `participants`, `responses`, e estrutura para campos extras customizados
- **Rotas**: três áreas distintas — `/admin/*` (dono da plataforma), `/organizer/*` ou similar (organizadores logados), e rotas públicas curtas para campanhas (ex: `/c/:slug`)
- **Requisito não-funcional**: a tela pública do participante deve ter footprint mínimo (sem assets pesados) — restrição arquitetural desde o dia 1
- **Fora de escopo (próximos módulos)**: modo ao vivo síncrono para palestrantes, notificações por email transacional além do reset de senha, dashboards com métricas, temas/customização visual, webhooks, multi-idioma, meta de carga de 1000 simultâneos
