# Quiz — Estande

Quiz gamificado para estandes de eventos. Organizadores criam quizzes, lançam
campanhas, geram QR code e coletam respostas; participantes escaneiam o QR e
respondem direto do celular, sem login.

## Stack

- Rails 8.1, Ruby (ver `.ruby-version`)
- MySQL 8 (gem `mysql2`)
- Bootstrap 5 via `cssbundling-rails`
- Hotwire (Turbo + Stimulus mínimo)
- Solid Queue / Solid Cache / Solid Cable nativos

## Setup local

```bash
bundle install
yarn install # ou npm install
bin/rails db:create db:migrate db:seed
bin/dev
```

O `db:seed` cria um administrador inicial — confira `db/seeds.rb` para o
email/senha padrão e troque imediatamente em produção.

## Áreas da aplicação

- `/cadastro`, `/entrar` — cadastro e login do organizador
- `/organizador/...` — painel do organizador (quizzes, campanhas, perguntas, resultados)
- `/admin/entrar`, `/admin/organizadores` — painel do dono da plataforma (aprova organizadores)
- `/c/:slug` — rota pública do participante (acessada via QR code)

## ⚠️ Tela do participante: footprint mínimo

A tela em `/c/:slug` é o caminho crítico do MVP — precisa funcionar bem em
**wifi de evento saturado / 4G ruim**. Restrição arquitetural desde o dia 1.

**Não faça isso na tela do participante:**

- ❌ Stimulus controllers, JS extra, libs front-end
- ❌ Imagens decorativas, ícones, fontes web
- ❌ Componentes JS pesados (modais animados, carrosséis)
- ❌ Polling, websockets, requisições AJAX intermediárias
- ❌ Renderização client-side de qualquer parte da página

**Faça assim:**

- ✅ HTML server-rendered + Bootstrap utilitários
- ✅ Um único form submit por etapa (Turbo se preciso)
- ✅ System font stack
- ✅ Layout dedicado: `app/views/layouts/participante.html.erb`

Se for tentado a "só adicionar uma coisinha" — não. Cada KB paga imposto de
rede ruim. Otimização posterior é reescrita.

## Como rodar (dev)

```bash
bin/dev
```

Letter Opener intercepta emails (reset de senha, etc) em desenvolvimento e
abre no navegador.
