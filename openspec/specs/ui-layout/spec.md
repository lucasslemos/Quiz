## Requirements

### Requirement: Layout base usa Bootstrap 5
O layout principal da aplicação (`app/views/layouts/application.html.erb`) SHALL carregar Bootstrap 5 como sua biblioteca de UI, via `stylesheet_link_tag "application"` (CSS empacotado pelo cssbundling-rails) e via importação do JS do Bootstrap em `app/javascript/application.js` empacotado pelo esbuild.

#### Scenario: Página renderiza componente do Bootstrap
- **WHEN** uma view usa uma classe do Bootstrap (ex.: `class="btn btn-primary"`)
- **THEN** o componente DEVE renderizar com os estilos aplicados sem necessidade de CSS adicional

#### Scenario: Componente JS do Bootstrap é usado
- **WHEN** uma view usa um componente que requer JavaScript do Bootstrap (dropdown, modal, offcanvas, tooltip)
- **THEN** o componente DEVE funcionar sem importação adicional na view, pois o JS do Bootstrap já está em `application.js`

### Requirement: Estrutura mínima do layout principal
O `app/views/layouts/application.html.erb` SHALL conter, no mínimo: `<!DOCTYPE html>`, `<html lang="pt-BR">`, `<meta charset="utf-8">`, `<meta name="viewport" content="width=device-width, initial-scale=1">`, `csrf_meta_tags`, `csp_meta_tags`, `stylesheet_link_tag "application"`, `javascript_include_tag "application", type: "module"`, e o `yield` envolvido por um landmark `<main>` dentro de um `.container` ou `.container-fluid` do Bootstrap.

#### Scenario: Layout é renderizado
- **WHEN** qualquer página da aplicação é renderizada
- **THEN** o HTML resultante DEVE conter `<html lang="pt-BR">`, `<meta name="viewport" ...>`, link para a stylesheet `application` e script `application` como módulo

#### Scenario: Conteúdo principal está em landmark semântico
- **WHEN** uma view é renderizada dentro do layout
- **THEN** o conteúdo do `yield` DEVE estar dentro de um elemento `<main>` para acessibilidade

### Requirement: Bootstrap antes de CSS customizado
Propostas e implementações SHALL preferir componentes, grid e utilitários do Bootstrap 5 antes de escrever CSS customizado, e CSS customizado SHALL ser usado apenas quando o Bootstrap não cobrir o caso ou quando for necessário sobrescrever variáveis SCSS via parciais importados pelo SCSS de entrada.

#### Scenario: Tarefa propõe CSS custom para algo coberto pelo Bootstrap
- **WHEN** uma tarefa adiciona CSS customizado para espaçamento, alinhamento, cor primária, grid ou tipografia
- **THEN** a tarefa DEVE ser reescrita usando utilitários/variáveis do Bootstrap (ex.: `mt-3`, `text-primary`, `row`/`col-*`) antes de aceitar CSS custom

#### Scenario: Customização de tema
- **WHEN** é necessário customizar cores, fontes ou breakpoints do Bootstrap
- **THEN** a customização DEVE ser feita sobrescrevendo variáveis SCSS do Bootstrap em um parcial importado pelo SCSS de entrada antes do `@import "bootstrap/scss/bootstrap"`

### Requirement: JS do Bootstrap importado em application.js
O arquivo `app/javascript/application.js` SHALL conter `import "bootstrap"` (ou equivalente que exponha `window.bootstrap`) para habilitar os componentes interativos do Bootstrap em toda a aplicação.

#### Scenario: application.js é empacotado
- **WHEN** o esbuild processa `app/javascript/application.js`
- **THEN** o bundle resultante DEVE incluir o JS do Bootstrap

### Requirement: SCSS de entrada importa Bootstrap completo
O arquivo SCSS de entrada do `cssbundling-rails` (criado pelo gerador `-c bootstrap`, tipicamente `app/assets/stylesheets/application.bootstrap.scss`) SHALL importar `bootstrap/scss/bootstrap` e SHALL ser o ponto único de entrada do CSS empacotado.

#### Scenario: Build de CSS é executado
- **WHEN** `yarn build:css` (ou comando equivalente do `cssbundling-rails`) roda
- **THEN** o CSS resultante DEVE incluir todo o Bootstrap 5

### Requirement: Acessibilidade básica do layout
O layout principal SHALL declarar `lang="pt-BR"`, prover `<main>` como landmark do conteúdo principal e, quando incluir navegação global, usá-la dentro de `<nav>` com componentes `navbar` do Bootstrap.

#### Scenario: Leitor de tela navega pela página
- **WHEN** um leitor de tela percorre a página
- **THEN** ele DEVE encontrar o landmark `main` e, se houver navegação, o landmark `navigation`

### Requirement: Sem CDN para Bootstrap
O Bootstrap NÃO DEVE ser carregado via CDN (`<link>`/`<script>` apontando para domínio externo); o carregamento SHALL ocorrer exclusivamente pelos pipelines `cssbundling-rails` e `jsbundling-rails`.

#### Scenario: Layout tenta incluir Bootstrap via CDN
- **WHEN** uma proposta adiciona `<link href="https://cdn.jsdelivr.net/.../bootstrap...">` no layout
- **THEN** a proposta DEVE ser rejeitada — usar o pipeline empacotado
