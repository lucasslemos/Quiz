## Context

Projeto Rails 8.1 recém-iniciado, praticamente vazio. O MVP do módulo Estande precisa entregar um produto ponta-a-ponta que um organizador real consiga usar sozinho num evento real, sem pedir ajuda ao dono da plataforma. Decisões tomadas em explore mode com o usuário definiram um SaaS multi-tenant gratuito, com aprovação manual de organizadores, participantes efêmeros (sem conta), QR code apontando para Campanha (não direto pro Quiz), critério binário de ganhador (acertou tudo), e três campos especiais fixos do participante mais campos extras customizáveis.

Restrição transversal mais importante: a tela pública do participante precisa funcionar bem em wifi de evento saturado / 4G ruim. Isso é decisão arquitetural desde o dia 1 — não dá pra "otimizar depois" sem reescrever.

## Goals / Non-Goals

**Goals:**
- Entregar fluxo ponta-a-ponta do organizador: cadastro → aprovação → criar quiz → criar campanha → gerar QR → coletar respostas → exportar ganhadores
- Tela pública do participante leve, rápida, tolerante a rede ruim
- Modelo de dados que já comporta campos extras customizados, mesmo que UI inicial entregue só os três fixos
- Aprovação manual de organizadores via painel `/admin` simples
- Bloqueio de resposta única "best effort": cookie sempre, email/telefone quando preenchidos

**Non-Goals:**
- Modo ao vivo síncrono (palestrante com timer, ranking ao vivo) — próximo módulo, não este
- Verificação real de email/telefone (sem envio de SMS, sem confirmação de email pra participante)
- Anti-trapaça forte (usuário disse explicitamente que não se importa)
- Notificações por email automáticas ao organizador (apenas reset de senha usa email)
- Dashboards, métricas, gráficos — lista simples + CSV bastam
- Temas/customização visual de quiz pelo organizador
- Suporte real a 1000 participantes simultâneos (meta de carga vem depois; MVP valida com dezenas a centenas)
- Multi-idioma — interface em pt-BR

## Decisions

### Decisão 1 — Stack e padrão arquitetural
**Escolha:** Rails 8.1 monolito clássico, Hotwire (Turbo + Stimulus mínimo), **Bootstrap 5** (via `cssbundling-rails`, conforme spec `ui-layout`), **MySQL** em todos os ambientes (gem `mysql2`, conforme spec `project-stack`). Solid Queue / Solid Cache / Solid Cable nativos do Rails 8.1.

**Rationale:** Rails 8.1 já entrega gerador de auth, Solid Queue, Solid Cable nativos sem gems extras. Hotwire mantém JS mínimo, o que casa diretamente com o requisito de "tela leve para 4G ruim" do participante. Bootstrap 5 é a stack travada do projeto (`rails new ... -c bootstrap`), oferece componentes prontos (navbar, cards, forms, modais) e CSS purgável em build. MySQL é o adapter travado do projeto (`rails new ... --database=mysql`).

**Alternativas consideradas:** SPA React/Vue (descartado: peso de JS, viola requisito de tela leve); Sinatra/Hanami (descartado: time-to-market pior, sem auth pronto).

### Decisão 2 — Três áreas distintas com namespaces de rota separados
**Escolha:**
```
/admin/*               → painel do dono da plataforma (auth separado ou role)
/organizer/*           → área logada do organizador
/c/:campaign_slug      → tela pública do participante (rota curta proposital)
```

**Rationale:** Separação clara de contextos evita misturar lógica de autenticação e autorização. A rota pública curta (`/c/:slug`) é importante para a URL de backup do QR code (precisa ser legível e fácil de digitar manualmente em caso de leitor de QR ruim).

**Alternativas consideradas:** Subdomínios (organizer.app, admin.app) — descartado por complicar dev local e não trazer benefício real no MVP.

### Decisão 3 — Admin como conta separada (não role no Organizer)
**Escolha:** Modelo `Admin` separado do modelo `Organizer`. Admins logam em `/admin/login`, organizadores em `/login`. Sem mistura.

**Rationale:** Admin é "dono da plataforma" (tipicamente 1-2 pessoas, você). Misturar com organizador via flag `is_admin` cria risco de escalonamento de privilégio acidental e polui o modelo de organizador com lógica que ele não usa. Separação física é mais segura para o MVP.

**Trade-off:** Duplica um pouco da lógica de auth. Aceitável dado o tamanho.

### Decisão 4 — Estado de aprovação como enum no Organizer
**Escolha:** `Organizer` tem campo `status` (enum: `pending`, `approved`, `rejected`, `suspended`). Organizador `pending` pode logar mas só vê uma tela "aguardando aprovação". Apenas `approved` pode criar quiz/campanha.

**Rationale:** Mantém o organizador no banco desde o cadastro (auditoria, evita re-cadastro), mas bloqueia acesso a funcionalidades. Soft state, fácil de mudar.

### Decisão 5 — Modelagem dos campos do participante
**Escolha:** Dois conceitos distintos:

```
Quiz
 ├── colunas dedicadas para identificadores
 │     - nome_obrigatorio: true (sempre, não editável)
 │     - email_state: enum [not_asked, optional, required]
 │     - phone_state: enum [not_asked, optional, required]
 │
 └── campos_personalizados (has_many CampoPersonalizado)
       - rotulo: "Empresa"
       - tipo_campo: enum [text, email, phone, select]
       - obrigatorio: boolean
       - opcoes: JSON (para select)
       - posicao: integer

Participacao (efêmera, vinculada a Campanha)
 ├── nome (string, sempre presente)
 ├── email (string, nullable)
 ├── telefone (string, nullable)
 └── valores_campo_personalizado (has_many; campo_personalizado_id + valor)
```

Convenção de nomes seguida em todo o módulo: pt-BR sem acentos
(`Organizador`, `Campanha`, `Pergunta`, `OpcaoResposta`, `Participacao`,
`CampoPersonalizado`, `ValorCampoPersonalizado`), conforme regra normativa
em `openspec/specs/project-stack/spec.md` e inflexões em
`config/initializers/inflections.rb`. `Quiz` permanece em inglês por ser o
nome do app/módulo raiz do projeto.

**Rationale:** Os três campos especiais (nome, email, telefone) ficam como **colunas dedicadas** em `participants` porque o sistema precisa raciocinar sobre eles (regra de bloqueio anti-duplicata por email/telefone). Os campos extras vão por uma estrutura relacional simples (não EAV completo) para suportar a flexibilidade prometida sem complicar queries.

**Alternativas consideradas:**
- Tudo em JSON num campo `data` — descartado: queries por email/telefone para anti-duplicata ficam ruins.
- EAV completo (todos os campos como linhas em uma tabela única) — descartado: complexidade desnecessária pro MVP.

### Decisão 6 — Regra de "uma resposta por participante" (best-effort em camadas)
**Escolha:** Ao receber uma submissão de participação numa Campanha, o sistema verifica em ordem:
1. Existe `Participation` com mesmo `campaign_id` e cookie (`participant_token` gerado no primeiro acesso e gravado em cookie HttpOnly de longa duração)?
2. Email foi preenchido E existe `Participation` com mesmo `campaign_id` + email (case-insensitive)?
3. Telefone foi preenchido E existe `Participation` com mesmo `campaign_id` + telefone (normalizado)?

Se qualquer um bater → bloqueia com mensagem amigável "você já participou desta campanha".

**Rationale:** Cobre os casos honestos (90% via cookie, mais via dados se preenchidos) sem prometer o que não dá. Se o organizador deixou tudo opcional e o participante limpou cookie → responde de novo, e tudo bem (organizador foi avisado dessa fragilidade ao criar o quiz).

### Decisão 7 — Aviso de fragilidade quando todos identificadores são opcionais
**Escolha:** Ao salvar a configuração de campos do quiz, se nenhum identificador (email/telefone) estiver no estado `required`, o sistema mostra um banner não-bloqueante na tela de gestão do quiz e na tela de criação da campanha:

> ⚠️ Sem campos de identificação obrigatórios, o sistema só consegue bloquear respostas duplicadas por navegador (cookie). Se for crítico evitar duplicatas (ex: prêmio em jogo), torne email ou telefone obrigatório.

**Rationale:** Respeita a autonomia do organizador (Saída 2 escolhida em explore mode), não bloqueia o fluxo, mas torna a consequência visível.

### Decisão 8 — Campanha como entidade de primeira classe
**Escolha:** Campanha é uma entidade separada do Quiz, com `slug` único, `name`, `quiz_id`, `starts_at`/`ends_at` opcionais (pode ser nula = sempre aberta), `status` (`draft`, `active`, `closed`).

**Rationale:** Permite reusar o mesmo Quiz em múltiplos eventos com resultados separados (cenário Microsoft levando o mesmo quiz pra AWS Summit e pra Web Summit). O QR code aponta sempre pra Campanha, nunca pro Quiz diretamente.

### Decisão 9 — QR code e URL curta
**Escolha:** Usar gem `rqrcode` para gerar PNG/SVG do QR code on-the-fly (cache em disco/Active Storage). URL curta = `/c/:slug` onde `slug` é gerado a partir do nome da campanha (com fallback para um hash curto se houver colisão). Slug é editável pelo organizador antes de publicar a campanha.

**Rationale:** `rqrcode` é a opção padrão em Ruby, sem dependências nativas pesadas. URL curta legível ajuda o caso de leitor de QR ruim ("digita aí: quiz.app/c/aws-summit").

### Decisão 10 — Tela do participante: footprint mínimo
**Escolha:**
- Layout dedicado (`participant.html.erb`), separado do layout do organizador
- Sem Stimulus controllers (ou só um único controller minúsculo se realmente necessário)
- Bootstrap 5 carregado normalmente (já travado pela spec `ui-layout`); preferir utilitários (`btn`, `form-control`, grid) a CSS custom; sem ícones, sem componentes JS pesados
- Sem imagens decorativas, sem fontes web (system font stack)
- Server-rendered tudo; Turbo apenas para o submit final (evita full page reload)
- HTML semântico, sem componentes pesados
- Resposta única do servidor cabe num pacote pequeno

**Rationale:** É o requisito não-funcional mais importante do MVP. Tudo que entra na tela do participante paga "imposto de rede ruim". Melhor cortar agora do que descobrir no evento real.

### Decisão 11 — Export CSV
**Escolha:** Botão "Exportar CSV" na tela de respostas da campanha. Gera CSV síncrono via `CSV.generate` (volume baixo no MVP, dispensa job em background). Colunas: nome, email, telefone, todos os campos custom, pontuação, acertou-tudo (sim/não), timestamp.

**Rationale:** Síncrono é mais simples e funciona pra centenas de respostas. Quando passar disso, vira job; mas isso é problema do próximo módulo.

## Risks / Trade-offs

- **[Risco] Cookie limpo / aba anônima burla "uma vez só"** → Mitigação: organizador é avisado quando todos identificadores são opcionais; pode tornar email/telefone obrigatório se for crítico.
- **[Risco] Slug colidindo entre campanhas de organizadores diferentes** → Mitigação: slug global único no MVP (mais simples); se virar problema, pode ser por organizador no futuro.
- **[Risco] CSV síncrono pode timeout em campanhas muito grandes** → Mitigação: aceitável no MVP (escopo pequeno); jobs em background entram quando volume justificar.
- **[Risco] Organizador esquece senha na véspera do evento** → Mitigação: reset de senha por email no MVP é obrigatório (não cortar).
- **[Risco] Modelo dual de auth (Admin + Organizer) cria duplicação** → Mitigação: aceitável no MVP, prioriza segurança; consolidar só se virar dor real.
- **[Trade-off] Tela do participante minimalista pode parecer "feia" comparada a concorrentes** → Aceito explicitamente: rede ruim > beleza no contexto de evento.
- **[Trade-off] Não verificamos email/telefone do participante** → Alguém pode digitar "x@x.com" e burlar bloqueio por email. Aceito: anti-trapaça forte é não-objetivo declarado.

## Open Questions

- **Hospedagem alvo?** Não bloqueia o MVP, mas influencia como configurar Active Storage, secrets, etc. Pode ser definido depois.
- **Slug por organizador ou global?** Decidi global no MVP por simplicidade; revisar se virar dor.
- **Soft delete de quiz/campanha?** Não decidido; provavelmente delete real no MVP, com confirmação dupla quando há respostas associadas.
