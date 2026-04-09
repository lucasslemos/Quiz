## Context

O projeto Quiz nasceu do comando `rails new Quiz --database=mysql -T -j esbuild -c bootstrap`. As escolhas embutidas nesse comando (MySQL, sem framework de testes default, esbuild para JS, Bootstrap via cssbundling) são restrições estruturais — qualquer divergência exige re-trabalho significativo (trocar adapter, reconfigurar bundler, reescrever assets). Hoje essas restrições só existem como conhecimento tácito: o `openspec/config.yaml` cita parte delas, mas não há uma fonte normativa em `openspec/specs/` que propostas futuras possam referenciar e que o fluxo de archive consolide.

Stakeholders: o próprio mantenedor (decisão de stack) e qualquer agente/IA gerando propostas via OpenSpec, que precisa de um contrato claro do que é imutável.

## Goals / Non-Goals

**Goals:**
- Tornar normativas, em `openspec/specs/project-stack/`, as restrições derivadas do comando de criação.
- Especificar o layout base da aplicação usando Bootstrap 5 (`openspec/specs/ui-layout/`), incluindo carregamento de CSS/JS, estrutura mínima do `application.html.erb` e diretriz de "Bootstrap antes de CSS custom".
- Garantir que o estado atual do código (`app/views/layouts/application.html.erb`, `app/javascript/application.js`, SCSS de entrada, `package.json`) está alinhado à spec; ajustar apenas o que estiver faltando.
- Manter pt-BR no `<html lang>` e na configuração de I18n.

**Non-Goals:**
- Não desenhar telas/páginas de domínio (quiz, perguntas, booth) — isso fica para propostas específicas.
- Não introduzir tema visual customizado, design system próprio nem biblioteca de componentes além do Bootstrap.
- Não decidir estratégia de testes (o `-T` é respeitado; a escolha de Minitest/RSpec/etc. é proposta separada).
- Não tocar em deploy (Kamal) nem em infraestrutura de jobs (Solid Queue).

## Decisions

### Decisão 1: Criar duas capabilities separadas (`project-stack` e `ui-layout`) em vez de uma só
- **Por quê:** `project-stack` é uma restrição de plataforma (raramente muda, citada por toda proposta futura). `ui-layout` é específica de frontend e pode evoluir (ex.: adicionar dark mode, navbar fixa) sem reabrir a discussão da stack.
- **Alternativa considerada:** uma única capability `architecture`. Rejeitada porque misturaria níveis de abstração e tornaria o archive de futuras mudanças de UI mais ruidoso.

### Decisão 2: Bootstrap 5 carregado via cssbundling-rails (SCSS) + esbuild (JS), não via CDN
- **Por quê:** é exatamente o que `-c bootstrap -j esbuild` configura. CDN quebraria o pipeline de assets do Propshaft, dificultaria versionamento e tiraria a possibilidade de customizar variáveis SCSS no futuro.
- **Alternativa considerada:** importmap + Bootstrap via CDN. Rejeitada — contradiz `-j esbuild`.

### Decisão 3: "Bootstrap antes de CSS custom" como requisito normativo
- **Por quê:** evita proliferação de CSS ad-hoc e mantém consistência visual. Componentes/utilitários do Bootstrap cobrem 90% dos casos do MVP do Quiz.
- **Trade-off:** layouts muito específicos podem ficar verbosos em utilitários; aceitável nessa fase.

### Decisão 4: Proibir explicitamente alternativas (Tailwind, importmap, PostgreSQL, Sprockets, Sidekiq/Redis) na spec
- **Por quê:** a spec serve como gate para propostas futuras geradas por IA. Listar o que é proibido é mais eficaz do que só listar o que é permitido.
- **Alternativa considerada:** deixar implícito. Rejeitada — já houve sugestões fora da stack em conversas anteriores.

### Decisão 5: I18n e acessibilidade fazem parte da spec `ui-layout`
- `<html lang="pt-BR">` obrigatório; `config.i18n.default_locale = :"pt-BR"`; navbar/contêiner devem usar landmarks semânticos (`<nav>`, `<main>`).

## Risks / Trade-offs

- **Risco:** travar Bootstrap 5 pode dificultar adoção futura de outra biblioteca.
  → **Mitigação:** mudança de UI exigirá nova proposta dedicada — comportamento desejado, não bug.
- **Risco:** restrições muito rígidas podem bloquear experimentação legítima.
  → **Mitigação:** a própria spec admite override via nova proposta justificada; nada é permanente, só explícito.
- **Risco:** spec ficar desatualizada se versões mudarem (Rails 8.2, Bootstrap 6).
  → **Mitigação:** versões maiores entram como nova proposta `MODIFIED Requirements` na mesma capability.
- **Trade-off:** verbosidade de utilitários Bootstrap em telas complexas vs. consistência. Aceito.

## Migration Plan

1. Criar specs `project-stack` e `ui-layout` (este change).
2. Verificar `app/views/layouts/application.html.erb`, `app/javascript/application.js`, SCSS de entrada e `package.json` — ajustar apenas onde divergir da spec.
3. Confirmar `config.i18n.default_locale = :"pt-BR"` e `<html lang="pt-BR">`.
4. Rodar `bin/dev` e validar visualmente que Bootstrap está aplicado (ex.: `.btn.btn-primary` renderiza estilizado).
5. Sem rollback necessário — mudanças são de configuração/layout e versionadas em git.

## Open Questions

- Adotar Bootstrap Icons agora ou só quando a primeira tela precisar? (Sugestão: adiar até a primeira proposta de UI que precise de ícones.)
- Customizar variáveis SCSS do Bootstrap (cores, fontes) já neste change ou deixar default? (Sugestão: deixar default; customização vira proposta de "tema" depois.)
