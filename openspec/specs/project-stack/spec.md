## Requirements

### Requirement: Comando de criação do projeto é imutável
O projeto SHALL ser tratado como tendo sido criado pelo comando `rails new Quiz --database=mysql -T -j esbuild -c bootstrap`, e nenhuma proposta DEVE introduzir mudanças que contradigam as flags desse comando sem uma nova proposta dedicada que justifique a quebra.

#### Scenario: Proposta sugere trocar o banco de dados
- **WHEN** uma proposta sugere migrar o adapter de banco para algo diferente de MySQL (ex.: PostgreSQL, SQLite)
- **THEN** a proposta DEVE ser rejeitada salvo se for uma proposta dedicada à substituição completa da stack de banco, com plano de migração de dados e atualização desta capability

#### Scenario: Proposta sugere trocar o bundler de JavaScript
- **WHEN** uma proposta sugere usar importmap, webpack, vite ou rollup no lugar do esbuild
- **THEN** a proposta DEVE ser rejeitada — `-j esbuild` é a escolha travada

#### Scenario: Proposta sugere trocar a stack de CSS
- **WHEN** uma proposta sugere usar Tailwind, PostCSS isolado ou outra biblioteca de UI no lugar do Bootstrap via cssbundling-rails
- **THEN** a proposta DEVE ser rejeitada — `-c bootstrap` é a escolha travada

### Requirement: Banco de dados MySQL
O sistema SHALL usar MySQL como banco de dados em todos os ambientes, através da gem `mysql2 ~> 0.5`, e migrations DEVEM ser compatíveis com MySQL (charset `utf8mb4`, limites de chave de 3072 bytes, FKs explícitas).

#### Scenario: Migration usa tipo incompatível com MySQL
- **WHEN** uma migration usa um tipo de coluna ou recurso exclusivo de outro adapter (ex.: `jsonb`, arrays nativos do PostgreSQL)
- **THEN** a migration DEVE ser reescrita usando equivalentes suportados pelo MySQL (`json`, tabela auxiliar)

#### Scenario: Nova tabela é criada
- **WHEN** uma migration cria uma nova tabela
- **THEN** ela DEVE herdar `utf8mb4` (default do projeto) e respeitar o limite de 3072 bytes em índices compostos de strings

### Requirement: Projeto sem framework de testes default
O projeto SHALL respeitar a flag `-T` usada na criação: nenhum código DEVE assumir a existência implícita de Minitest, e qualquer adoção de framework de testes (Minitest, RSpec, etc.) DEVE ser feita via proposta dedicada.

#### Scenario: Tarefa cita "rodar rails test"
- **WHEN** uma tarefa de implementação assume `bin/rails test` como comando padrão
- **THEN** a tarefa DEVE ser revisada — não há suíte de testes configurada por padrão neste projeto

### Requirement: JavaScript via jsbundling-rails + esbuild
O sistema SHALL empacotar JavaScript exclusivamente via `jsbundling-rails` com o bundler `esbuild`, e o ponto de entrada SHALL ser `app/javascript/application.js`.

#### Scenario: Nova dependência JS é adicionada
- **WHEN** uma proposta adiciona uma dependência JavaScript
- **THEN** ela DEVE ser instalada via `yarn add` (ou `npm install`) e importada em `app/javascript/application.js` ou em um módulo importado por ele

### Requirement: CSS via cssbundling-rails + Bootstrap 5
O sistema SHALL empacotar CSS via `cssbundling-rails` tendo Bootstrap 5 como base, com um arquivo de entrada SCSS que importa `bootstrap/scss/bootstrap`.

#### Scenario: Nova folha de estilo é adicionada
- **WHEN** uma proposta adiciona estilos customizados
- **THEN** os estilos DEVEM ser adicionados ao SCSS de entrada (ou a um parcial importado por ele), nunca via `<style>` inline em layouts ou via Sprockets

### Requirement: Asset pipeline Propshaft
O sistema SHALL usar Propshaft como asset pipeline, e propostas NÃO DEVEM reintroduzir Sprockets.

#### Scenario: Proposta tenta usar helpers/recursos do Sprockets
- **WHEN** uma proposta usa diretivas como `//= require` ou helpers exclusivos do Sprockets
- **THEN** ela DEVE ser reescrita usando o modelo do Propshaft (imports via bundler, `asset_path`)

### Requirement: Stack Solid do Rails 8 para jobs, cache e cable
O sistema SHALL usar Solid Queue (jobs), Solid Cache (cache) e Solid Cable (Action Cable) como adapters, e propostas NÃO DEVEM substituí-los por Sidekiq, Redis ou outros sem nova proposta dedicada.

#### Scenario: Proposta sugere Sidekiq
- **WHEN** uma proposta adiciona Sidekiq ou Redis para jobs/cache
- **THEN** ela DEVE ser rejeitada salvo se for uma proposta dedicada à substituição da stack Solid, com justificativa de capacidade ou desempenho

### Requirement: Versões de Ruby e Rails travadas
O projeto SHALL usar Ruby `4.0.1` (declarado em `.ruby-version`) e Rails `~> 8.1.2` (declarado no `Gemfile`), e propostas DEVEM respeitar a sintaxe e APIs disponíveis nessas versões.

#### Scenario: Proposta usa API removida ou ainda não disponível
- **WHEN** uma proposta usa uma API que não existe em Rails 8.1 ou sintaxe Ruby fora da versão 4.0.1
- **THEN** a proposta DEVE ser ajustada para a versão travada

### Requirement: Idioma e localização padrão pt-BR
O sistema SHALL ter `:"pt-BR"` como `default_locale` do I18n e textos voltados ao usuário DEVEM residir em `config/locales/pt-BR.yml`.

#### Scenario: Texto hardcoded em view
- **WHEN** uma view contém string voltada ao usuário diretamente em ERB
- **THEN** a string DEVE ser movida para `config/locales/pt-BR.yml` e referenciada via `t("...")`

### Requirement: Nomenclatura de código em pt-BR
Models, controllers, services, jobs, helpers, concerns, mailers, métodos e variáveis de domínio SHALL usar nomes em Português do Brasil, e o projeto SHALL manter um inflector pt-BR registrado em `config/initializers/inflections.rb` para que Zeitwerk e Active Record resolvam corretamente as pluralizações sem necessidade de declarar `self.table_name` em cada classe. Nomes SHALL ser escritos sem acentos, til ou cedilha (apenas em strings/views/locales). Palavras-chave e APIs do Rails (`ApplicationController`, `ApplicationRecord`, ações REST padrão `index/show/new/create/edit/update/destroy`, macros como `has_many`, `belongs_to`, `before_action`, `validates`) e o nome do app `Quiz` SHALL permanecer em inglês.

#### Scenario: Novo model de domínio
- **WHEN** uma proposta cria um novo model de domínio (ex.: organizador, campanha, pergunta)
- **THEN** o nome da classe DEVE ser em pt-BR sem acentos (ex.: `Organizador`, `Campanha`, `Pergunta`, `Participacao`, `OpcaoResposta`) e a tabela DEVE ser a forma plural pt-BR correspondente (`organizadores`, `campanhas`, `perguntas`, `participacoes`, `opcoes_resposta`)

#### Scenario: Pluralização irregular ainda não registrada
- **WHEN** um novo termo de domínio é introduzido e a regra geral do inflector não pluraliza corretamente
- **THEN** uma `inflect.irregular(...)` DEVE ser adicionada ao `config/initializers/inflections.rb` antes de gerar o model

#### Scenario: Nome com acento ou cedilha
- **WHEN** uma proposta sugere uma classe, arquivo, tabela ou coluna com acentuação ou cedilha (ex.: `Participação`, `opção_resposta`)
- **THEN** o nome DEVE ser reescrito sem acento (ex.: `Participacao`, `opcao_resposta`); a acentuação fica apenas em strings de UI/locales

#### Scenario: Tentativa de traduzir API do framework
- **WHEN** uma proposta sugere renomear `ApplicationController`, `ApplicationRecord`, `ApplicationJob`, `ApplicationMailer` ou ações REST padrão
- **THEN** a sugestão DEVE ser rejeitada — convenções do Rails permanecem em inglês

#### Scenario: Código pré-existente em inglês
- **WHEN** uma proposta encontra código pré-existente com nomes em inglês
- **THEN** ela NÃO DEVE renomear apenas pela convenção; renomeações em massa exigem proposta dedicada
