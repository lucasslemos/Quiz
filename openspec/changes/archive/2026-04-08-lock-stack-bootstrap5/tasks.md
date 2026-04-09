## 1. Verificação do estado atual

- [x] 1.1 Confirmar que `Gemfile` declara `rails ~> 8.1.2`, `mysql2 ~> 0.5`, `jsbundling-rails`, `cssbundling-rails`, `propshaft`, `solid_queue`, `solid_cache`, `solid_cable`
- [x] 1.2 Confirmar que `.ruby-version` contém `4.0.1`
- [x] 1.3 Confirmar que `package.json` contém as dependências `bootstrap`, `@popperjs/core`, `esbuild`, `sass`
- [x] 1.4 Confirmar que `config/database.yml` usa o adapter `mysql2`
- [x] 1.5 Confirmar que não existe `test/` populado por gerador (respeitando `-T`); se existir, registrar pendência sem remover

## 2. Layout base com Bootstrap 5

- [x] 2.1 Abrir `app/views/layouts/application.html.erb` e garantir `<html lang="pt-BR">`
- [x] 2.2 Garantir `<meta charset="utf-8">` e `<meta name="viewport" content="width=device-width, initial-scale=1">`
- [x] 2.3 Garantir presença de `csrf_meta_tags` e `csp_meta_tags`
- [x] 2.4 Garantir `<%= stylesheet_link_tag "application" %>` no `<head>` (corrigido de `:app` para `"application"`, que é o nome real do bundle gerado pelo cssbundling-rails)
- [x] 2.5 Garantir `<%= javascript_include_tag "application", type: "module" %>` no `<head>`
- [x] 2.6 Envolver o `<%= yield %>` em um `<main class="container py-4">` (ou `container-fluid` conforme o caso)
- [x] 2.7 (Opcional) Adicionar uma `<nav class="navbar navbar-expand-lg ...">` mínima como exemplo de uso de componente

## 3. Pipeline de assets (Bootstrap)

- [x] 3.1 Verificar `app/javascript/application.js` — garantir `import "bootstrap"` (já presente como `import * as bootstrap from "bootstrap"`)
- [x] 3.2 Verificar SCSS de entrada (`app/assets/stylesheets/application.bootstrap.scss` ou equivalente) — garantir `@import "bootstrap/scss/bootstrap";`
- [x] 3.3 Conferir scripts `build` e `build:css` no `package.json` apontando para esbuild e sass
- [x] 3.4 Rodar `yarn install` (ou `npm install`) e validar que não há vulnerabilidades críticas

## 4. I18n pt-BR

- [x] 4.1 Garantir `config.i18n.default_locale = :"pt-BR"` em `config/application.rb`
- [x] 4.2 Criar (se ainda não existir) `config/locales/pt-BR.yml` com a chave raiz `pt-BR:`
- [x] 4.3 Garantir que `config.i18n.available_locales` inclui `:"pt-BR"`

## 5. Validação visual e funcional

- [x] 5.1 Rodar `bin/dev` e abrir a página inicial
- [x] 5.2 Validar que um `<button class="btn btn-primary">Teste</button>` adicionado temporariamente ao layout renderiza estilizado
- [x] 5.3 Validar que um componente JS do Bootstrap (ex.: dropdown) funciona sem importação adicional
- [x] 5.4 Remover qualquer marcação temporária de validação do layout
- [x] 5.5 Verificar `<html lang="pt-BR">` no HTML servido (DevTools)

## 6. Qualidade

- [x] 6.1 Rodar `bundle exec rubocop` e corrigir ofensas introduzidas
- [x] 6.2 Rodar `bundle exec brakeman` e validar ausência de novos alertas
- [x] 6.3 Rodar `bundle exec bundler-audit check --update` e validar dependências

## 7. Documentação e fechamento

- [x] 7.1 Atualizar `openspec/config.yaml` se algo nas restrições mudou durante a implementação (corrigido `spec:` → `specs:`)
- [x] 7.2 Commit em pt-BR seguindo Conventional Commits (ex.: `feat(layout): trava stack Bootstrap 5 e layout base`)
- [x] 7.3 Rodar `openspec status --change "lock-stack-bootstrap5"` e confirmar que tudo está `done`
- [ ] 7.4 Quando a implementação estiver concluída, arquivar via `/opsx:archive`
