## Why

O projeto Quiz foi criado com o comando `rails new Quiz --database=mysql -T -j esbuild -c bootstrap` e essa decisão precisa ser tratada como uma restrição arquitetural imutável: futuras propostas e implementações já começaram a sugerir alternativas (Tailwind, importmap, Minitest "padrão", PostgreSQL) que fugiriam dessa base. Precisamos travar formalmente a stack — incluindo Bootstrap 5 como biblioteca de UI obrigatória do layout — para que todo trabalho subsequente respeite o que já está posto.

## What Changes

- Formaliza, como capability versionada, as restrições de stack derivadas do comando de criação do projeto (`--database=mysql`, `-T`, `-j esbuild`, `-c bootstrap`).
- Define **Bootstrap 5** como a biblioteca de UI obrigatória do layout: componentes, grid e utilitários do Bootstrap devem ser preferidos a CSS customizado.
- Garante que o layout base da aplicação (`app/views/layouts/application.html.erb`) carrega Bootstrap 5 via `cssbundling-rails` e o JS do Bootstrap via `jsbundling-rails`/esbuild, com a navbar/contêiner mínimos prontos para uso.
- Proíbe explicitamente substituições da stack sem nova proposta dedicada (ex.: trocar MySQL por outro banco, importmap no lugar do esbuild, Tailwind no lugar do Bootstrap, reintrodução de Sprockets, adoção implícita de Minitest apesar do `-T`).
- **BREAKING** para qualquer rascunho/proposta em aberto que assuma stack diferente — precisará ser revisado.

## Capabilities

### New Capabilities
- `project-stack`: registra de forma normativa a stack do projeto (Ruby/Rails, MySQL, esbuild, Bootstrap 5, Hotwire, Solid Queue/Cache/Cable, Propshaft, Kamal) e as restrições não negociáveis derivadas do comando de criação.
- `ui-layout`: define o layout base da aplicação usando Bootstrap 5 — pacotes carregados, estrutura mínima do `application.html.erb`, padrões de uso de componentes/grid.

### Modified Capabilities
<!-- Nenhuma capability existente tem requisitos alterados por esta proposta. -->

## Impact

- **Documentação/processo**: `openspec/config.yaml` já reflete parte dessas restrições; esta proposta cria a fonte normativa em `openspec/specs/` que as propostas futuras devem citar.
- **Código afetado**:
  - `app/views/layouts/application.html.erb` — garantir `<%= stylesheet_link_tag "application" %>` e `<%= javascript_include_tag "application", type: "module" %>` carregando Bootstrap, e estrutura mínima (`container`, navbar opcional).
  - `app/javascript/application.js` — `import "bootstrap"` para habilitar componentes JS (dropdowns, modais, etc.).
  - `app/assets/stylesheets/application.bootstrap.scss` (ou equivalente gerado pelo `-c bootstrap`) — `@import "bootstrap/scss/bootstrap";`.
  - `package.json` — confirmar dependências `bootstrap`, `@popperjs/core`, `esbuild`, `sass` instaladas pelo gerador.
- **Dependências**: nenhuma nova gem; apenas confirmação das já presentes (`jsbundling-rails`, `cssbundling-rails`, `mysql2`).
- **Migrations/MySQL**: nenhuma — proposta puramente arquitetural/de layout.
- **Propostas futuras**: passam a ser obrigadas a respeitar a capability `project-stack`; qualquer divergência exige proposta dedicada justificando a quebra.
